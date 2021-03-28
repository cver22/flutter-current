import 'package:currency_picker/currency_picker.dart';
import '../../currency/currency_ui/app_currency_dialog.dart';
import '../../store/actions/single_entry_actions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/common_widgets/app_button.dart';
import '../../env.dart';

class AppCurrencyPicker extends StatelessWidget {
  final String currency;
  final Function(String) returnCurrency;
  final String logCurrency;

  const AppCurrencyPicker({Key key, this.currency, @required this.returnCurrency, @required this.logCurrency})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Currency _currency = CurrencyService().findByCode(currency ?? 'CAD');

    return AppButton(
      onPressed: () {
        Get.dialog(AppCurrencyDialog(
          title: 'Entry currency',
          logCurrency: logCurrency,
          returnCurrency: (currency) => Env.store.dispatch(EntryUpdateCurrency(currency: currency)),
        ));

        /*showCurrencyPicker(
          context: context,
          showFlag: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) {
            _currency = currency;
            widget.returnCurrency(currency.code);
          },
        );*/
      },
      child: Text('${CurrencyUtils.countryCodeToEmoji(_currency)} ${_currency.code}'),
    );
  }
}
