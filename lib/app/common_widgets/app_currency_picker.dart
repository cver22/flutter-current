import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';

class AppCurrencyPicker extends StatefulWidget {
  final String currency;
  final Function(String) returnCurrency;

  const AppCurrencyPicker({Key key, this.currency, this.returnCurrency}) : super(key: key);

  @override
  _AppCurrencyPickerState createState() => _AppCurrencyPickerState();
}

class _AppCurrencyPickerState extends State<AppCurrencyPicker> {
  Currency _currency;

  @override
  Widget build(BuildContext context) {
    _currency = CurrencyService().findByCode(widget.currency ?? 'CAD');


    return RaisedButton(
      onPressed: () {
        showCurrencyPicker(
          context: context,
          showFlag: true,
          showCurrencyName: true,
          showCurrencyCode: true,
          onSelect: (Currency currency) {
            _currency = currency;
            widget.returnCurrency(currency.code);
          },
        );
      },
      child: Text('${CurrencyUtils.countryCodeToEmoji(_currency)} ${_currency.code}'),
    );
  }
}