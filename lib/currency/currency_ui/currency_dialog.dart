import '../../store/actions/currency_actions.dart';
import '../../currency/currency_models/currency_state.dart';
import '../../app/common_widgets/app_dialog.dart';
import '../../env.dart';
import '../../store/connect_state.dart';
import '../../utils/utils.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'currency_list_tile.dart';

class CurrencyDialog extends StatefulWidget {
  final String title;
  final String referenceCurrency;
  final Function(String) returnCurrency;
  final bool withConversionRates;

  const CurrencyDialog(
      {Key key,
      @required this.title,
      @required this.referenceCurrency,
      @required this.returnCurrency,
      this.withConversionRates = false})
      : super(key: key);

  @override
  _CurrencyDialogState createState() => _CurrencyDialogState();
}

class _CurrencyDialogState extends State<CurrencyDialog> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState<CurrencyState>(
        where: notIdentical,
        map: (state) => state.currencyState,
        builder: (currencyState) {
          return AppDialogWithActions(
            topWidget: searchBox(),
            child: _buildCurrencyList(
              referenceCurrencyCode: widget.referenceCurrency,
              returnCurrency: widget.returnCurrency,
              withConversionRates: widget.withConversionRates,
              currencyState: currencyState,
            ),
            title: widget.title,
            actions: _actions(withConversionRates: widget.withConversionRates),
          );
        });
  }

  Widget searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(Icons.search_outlined),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(labelText: 'Search'),
              controller: _controller,
              autofocus: false,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]"))],
              textInputAction: TextInputAction.done,
              onChanged: (search) {
                setState(() {
                  Env.store.dispatch(CurrencySearchCurrencies(search: search));
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _actions({@required bool withConversionRates}) {
    return [
      if (withConversionRates)
        TextButton(
          child: Text('Refresh'),
          onPressed: () {
            Env.currencyFetcher.loadRemoteConversionRates(referenceCurrency: 'CAD');
          },
        ),
      TextButton(
          child: Text('Done'),
          onPressed: () {
            Get.back();
          }),
    ];
  }

  Widget _buildCurrencyList(
      {@required String referenceCurrencyCode,
      @required Function(String) returnCurrency,
      @required bool withConversionRates,
      @required CurrencyState currencyState}) {
    List<Currency> currencies = <Currency>[];
    Currency referenceCurrency = CurrencyService().findByCode(referenceCurrencyCode);

    if (currencyState.searchCurrencies.isNotEmpty) {
      currencies = currencyState.searchCurrencies;
    } else {
      currencies = currencyState.allCurrencies;
    }

    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        itemCount: currencies.length,
        itemBuilder: (BuildContext context, int index) {
          final Currency _currency = currencies[index];

          double conversionRate;

          if (withConversionRates && currencyState?.conversionRateMap[referenceCurrencyCode] != null) {
            conversionRate = currencyState?.conversionRateMap[referenceCurrencyCode]?.rates[_currency.code];
          }

          return CurrencyListTile(
              currency: _currency,
              conversionRate: conversionRate ?? 0.0,
              baseCurrency: referenceCurrency,
              returnCurrency: returnCurrency,
              withConversionRates: withConversionRates);
        });
  }
}
