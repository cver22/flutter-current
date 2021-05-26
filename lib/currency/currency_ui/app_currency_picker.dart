import 'package:currency_picker/currency_picker.dart';
import '../../currency/currency_ui/currency_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/common_widgets/app_button.dart';

class AppCurrencyPicker extends StatelessWidget {
  final Function(String) returnCurrency;
  final String? referenceCurrency;
  final bool withConversionRates;
  final String title;
  final String buttonLabel;
  final VoidCallback? unFocus;
  final List<Currency>? currencies;
  final bool multiSelect;

  const AppCurrencyPicker({
    Key? key,
    required this.returnCurrency,
    this.referenceCurrency,
    this.withConversionRates = false,
    required this.title,
    required this.buttonLabel,
    this.unFocus,
    this.currencies,
    this.multiSelect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: () {
        if (unFocus != null) {
          unFocus!();
        }
        Get.dialog(CurrencyDialog(
          title: title,
          withConversionRates: withConversionRates,
          referenceCurrency: referenceCurrency,
          onTap: returnCurrency,
          currencies: currencies,
          multiSelect: multiSelect,
        ));
      },
      child: Text(buttonLabel),
    );
  }
}
