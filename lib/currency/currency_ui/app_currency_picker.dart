import 'package:currency_picker/currency_picker.dart';
import '../../store/actions/currency_actions.dart';
import '../../currency/currency_ui/currency_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/common_widgets/app_button.dart';
import '../../env.dart';

class AppCurrencyPicker extends StatelessWidget {
  final String? currency;
  final Function(String) returnCurrency;
  final String? logCurrency;
  final bool withConversionRates;
  final String title;
  final VoidCallback? clearCallingFocus;
  final List<Currency>? currencies;
  final bool filterSelect;

  const AppCurrencyPicker({
    Key? key,
    this.currency = 'CAD', //TODO change this to localizations and required
    required this.returnCurrency,
    this.logCurrency,
    this.withConversionRates = false,
    required this.title,
    this.clearCallingFocus,
    this.currencies,
    this.filterSelect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Currency _currency = CurrencyService().findByCode(currency ?? 'CAD')!;

    return AppButton(
      onPressed: () {
        if (clearCallingFocus != null) {
          clearCallingFocus!();
        }
        Get.dialog(CurrencyDialog(
          title: title,
          withConversionRates: withConversionRates,
          referenceCurrency: logCurrency ?? _currency.code,
          returnCurrency: returnCurrency,
          searchFunction: (search) {
            Env.store.dispatch(CurrencySearchCurrencies(search: search));
          },
          currencies: currencies,
          filterSelect: filterSelect,
        ));
      },
      child: Text('${CurrencyUtils.currencyToEmoji(_currency)} ${_currency.code}'),
    );
  }
}
