import 'package:expenses/store/actions/currency_actions.dart';

import '../../store/actions/single_entry_actions.dart';

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

class AppCurrencyDialog extends StatefulWidget {
  final String title;
  final String logCurrency;
  final Function(String) returnCurrency;

  const AppCurrencyDialog({Key key, @required this.title, @required this.logCurrency, @required this.returnCurrency})
      : super(key: key);

  @override
  _AppCurrencyDialogState createState() => _AppCurrencyDialogState();
}

class _AppCurrencyDialogState extends State<AppCurrencyDialog> {
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
    Env.store.dispatch(EntryClearAllFocus());
    return AppDialogWithActions(
      topWidget: searchBox(),
      child: _buildCurrencyList(logCurrencyCode: widget.logCurrency, returnCurrency: widget.returnCurrency),
      title: widget.title,
      actions: _actions(),
    );
  }

  Widget searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
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

  List<Widget> _actions() {
    return [
      TextButton(
        child: Text('Refresh'),
        onPressed: () {
          //TODO refreshes exchange rates
        },
      ),
      TextButton(
          child: Text('Done'),
          onPressed: () {
            Get.back();
          }),
    ];
  }

  Widget _buildCurrencyList({@required String logCurrencyCode, @required Function(String) returnCurrency}) {
    List<Currency> currencies = <Currency>[];
    Currency logCurrency = CurrencyService().findByCode(logCurrencyCode);

    return ConnectState<CurrencyState>(
        where: notIdentical,
        map: (state) => state.currencyState,
        builder: (currencyState) {
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
                final double conversionRate =
                    0.00; //currencyState?.conversionRateMap[logCurrencyCode]?.conversionRates[_currency.code]; //TODO this needs better error checking
                return CurrencyListTile(
                    currency: _currency,
                    conversionRate: conversionRate,
                    logCurrency: logCurrency,
                    returnCurrency: returnCurrency);
              });
        });
  }
}
