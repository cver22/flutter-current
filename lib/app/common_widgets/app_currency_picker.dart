import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';

class MyCurrencyPicker extends StatefulWidget {
  final String currency;
  final Function(String) returnCurrency;

  const MyCurrencyPicker({Key key, this.currency, this.returnCurrency}) : super(key: key);

  @override
  _MyCurrencyPickerState createState() => _MyCurrencyPickerState();
}

class _MyCurrencyPickerState extends State<MyCurrencyPicker> {
  Currency _currency;

  @override
  Widget build(BuildContext context) {
    _currency = CurrencyService().findByCode(widget.currency);


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