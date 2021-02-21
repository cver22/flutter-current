import 'package:currency_pickers/country.dart';
import 'package:currency_pickers/currency_pickers.dart';
import 'package:flutter/material.dart';

class MyCurrencyPicker extends StatefulWidget {
  final String currency;
  final Function(String) returnCurrency;

  const MyCurrencyPicker({Key key, this.currency, this.returnCurrency}) : super(key: key);

  @override
  _MyCurrencyPickerState createState() => _MyCurrencyPickerState();
}

class _MyCurrencyPickerState extends State<MyCurrencyPicker> {
  String _currency;

  @override
  Widget build(BuildContext context) {
    _currency = widget.currency;
    return CurrencyPickerDropdown(
      //TODO change default local currency based on phone
      initialValue: _currency == null
          ? CurrencyPickerUtils.getCountryByCurrencyCode('CAD').isoCode
          : CurrencyPickerUtils.getCountryByCurrencyCode(_currency).isoCode,
      itemBuilder: _buildDropdownItem,
      onValuePicked: (Country country) {
        _currency = country.currencyCode;
        widget.returnCurrency(_currency);
      },
    );
  }

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CurrencyPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Text("${country.currencyCode}"),
          ],
        ),
      );
}
