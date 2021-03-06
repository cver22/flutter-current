import '../../store/actions/currency_actions.dart';

import '../../filter/filter_ui/filter_actions.dart';
import '../../app/common_widgets/list_tile_components.dart';
import '../../filter/filter_model/filter_state.dart';
import '../../store/actions/filter_actions.dart';
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
  final String? referenceCurrency;
  final Function(String) onTap;
  final bool withConversionRates;
  final List<Currency>? currencies;
  final bool multiSelect;

  const CurrencyDialog({
    Key? key,
    required this.title,
    this.referenceCurrency,
    required this.onTap,
    this.withConversionRates = false,
    this.currencies,
    this.multiSelect = false,
  }) : super(key: key);

  @override
  _CurrencyDialogState createState() => _CurrencyDialogState();
}

class _CurrencyDialogState extends State<CurrencyDialog> {
  TextEditingController? _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState<CurrencyState>(
        where: notIdentical,
        map: (state) => state.currencyState,
        builder: (currencyState) {
          return ConnectState<FilterState>(
              where: notIdentical,
              map: (state) => state.filterState,
              builder: (filterState) {
                return AppDialogWithActions(
                  topWidget: searchBox(
                    lastUpdated: currencyState.conversionRateMap[widget.referenceCurrency]?.lastUpdated,
                    withConversionRates: widget.withConversionRates,
                    currencies: widget.currencies,
                  ),
                  child: _buildCurrencyList(
                    referenceCurrencyCode: widget.referenceCurrency,
                    onTap: widget.onTap,
                    withConversionRates: widget.withConversionRates,
                    currencyState: currencyState,
                    currencies: widget.currencies,
                    multiSelect: widget.multiSelect,
                    selectedCurrencies: widget.multiSelect ? filterState.filter.value.selectedCurrencies : null,
                  ),
                  title: widget.title,
                  backChevron: () {
                    Env.store.dispatch(CurrencyClearSearch());
                    Get.back();
                  },
                  actions: widget.multiSelect
                      ? filterActions(
                          onPressedClear: () {
                            Env.store.dispatch(FilterClearCurrencySelection());
                          },
                        )
                      : _actions(
                          withConversionRates: widget.withConversionRates,
                          referenceCurrency: widget.referenceCurrency,
                        ),
                );
              });
        });
  }

  Widget searchBox({
    required DateTime? lastUpdated,
    required bool withConversionRates,
    List<Currency>? currencies,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        children: [
          if (lastUpdated != null && withConversionRates)
            Text('Updated: ${lastUpdated.year}/${lastUpdated.month}/${lastUpdated.day}',
                style: TextStyle(fontSize: 10.0, fontStyle: FontStyle.italic)),
          Row(
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
                      Env.store.dispatch(CurrencySearchCurrencies(search: search, currencies: currencies));
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _actions({required bool withConversionRates, String? referenceCurrency}) {
    return [
      if (withConversionRates)
        TextButton(
          child: Text('Refresh'),
          onPressed: () {
            Env.currencyFetcher.remoteLoadReferenceConversionRates(referenceCurrency: referenceCurrency!);
          },
        ),
      TextButton(
          child: Text('Done'),
          onPressed: () {
            Get.back();
          }),
    ];
  }

  Widget _buildCurrencyList({
    required String? referenceCurrencyCode,
    required Function(String) onTap,
    required bool withConversionRates,
    required CurrencyState currencyState,
    required bool multiSelect,
    required List<String>? selectedCurrencies,
    List<Currency>? currencies,
  }) {
    List<Currency> viewCurrencies = currencies ?? currencyState.allCurrencies;

    Currency? referenceCurrency = CurrencyService().findByCode(referenceCurrencyCode);

    if (currencyState.search.isSome && currencyState.search.value.length > 0) {
      viewCurrencies = currencyState.searchCurrencies;
    }

    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        itemCount: viewCurrencies.length,
        itemBuilder: (BuildContext context, int index) {
          final Currency _currency = viewCurrencies[index];

          double? conversionRate;

          if (withConversionRates && currencyState.conversionRateMap[referenceCurrencyCode] != null) {
            conversionRate = currencyState.conversionRateMap[referenceCurrencyCode]?.rates[_currency.code];
          }

          return CurrencyListTile(
            currency: _currency,
            conversionRate: conversionRate,
            referenceCurrency: referenceCurrency,
            onTap: onTap,
            withConversionRates: withConversionRates,
            trailingCheckBox: multiSelect
                ? FilterListTileTrailing(
                    onTap: () => onTap(_currency.code),
                    selected: selectedCurrencies!.contains(_currency.code),
                  )
                : null,
          );
        });
  }
}
