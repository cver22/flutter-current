import 'package:currency_picker/currency_picker.dart';
import '../../store/actions/currency_actions.dart';
import '../../currency/currency_ui/currency_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/common_widgets/app_button.dart';
import '../../env.dart';

class AppCurrencyPicker extends StatelessWidget {
  final Function(String) returnCurrency;
  final String? referenceCurrency;
  final bool withConversionRates;
  final String title;
  final String buttonLabel;
  final VoidCallback? unFocus;
  final List<Currency>? currencies;
  final bool filterSelect;

  const AppCurrencyPicker({
    Key? key,
    required this.returnCurrency,
    this.referenceCurrency,
    this.withConversionRates = false,
    required this.title,
    required this.buttonLabel,
    this.unFocus,
    this.currencies,
    this.filterSelect = false,
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
          searchFunction: (search) {
            Env.store.dispatch(CurrencySearchCurrencies(search: search));
          },
          currencies: currencies,
          filterSelect: filterSelect,
        ));
      },
      child: Text(buttonLabel),
    );
  }




  }

