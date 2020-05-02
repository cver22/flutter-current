import 'package:currency_pickers/currency_pickers.dart';
import 'package:expenses/models/log/log.dart';
import 'package:flutter/material.dart';


class LogListTile extends StatelessWidget {
  const LogListTile({Key key, @required this.log, this.onTap, this.onLongPress}) : super(key: key);
  final Log log;
  final VoidCallback onTap;
  final VoidCallback onLongPress;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(log.logName),
      subtitle: Text(CurrencyPickerUtils.getCountryByIsoCode(log.currency).currencyCode),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
