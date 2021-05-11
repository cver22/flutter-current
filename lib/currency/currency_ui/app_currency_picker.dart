import 'package:currency_picker/currency_picker.dart';
import '../../currency/currency_ui/currency_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/common_widgets/app_button.dart';

class AppCurrencyPicker extends StatelessWidget {
  final String? currency;
  final Function(String) returnCurrency;
  final String? logCurrency;
  final bool withConversionRates;
  final String title;
  final VoidCallback? clearCallingFocus;

  const AppCurrencyPicker(
      {Key? key,
      this.currency = 'CAD',
      required this.returnCurrency,
      this.logCurrency,
      this.withConversionRates = false,
      required this.title,
      this.clearCallingFocus})
      : super(key: key);

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
        ));
      },
      child: Text('${CurrencyUtils.currencyToEmoji(_currency)} ${_currency.code}'),
    );
  }
}
