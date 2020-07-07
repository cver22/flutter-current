import 'package:currency_pickers/currency_pickers.dart';
import 'package:expenses/env.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';

class LogListTile extends StatelessWidget {

  final Log log;

  const LogListTile({Key key, @required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(log.logName),
      subtitle: Text(
          CurrencyPickerUtils.getCountryByIsoCode(log.currency).currencyCode),
      trailing: Icon(Icons.chevron_right),
      onTap: () => {
        Env.store.dispatch(SelectLog(logId: log.id)),
        Navigator.pushNamed(context, ExpenseRoutes.addEditEntries),
      },
      onLongPress: () => {
        Env.store.dispatch(SelectLog(logId: log.id)),
        Navigator.pushNamed(context, ExpenseRoutes.addEditLog),
      },
    );
  }
}
