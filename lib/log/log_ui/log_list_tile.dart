import 'package:currency_pickers/currency_pickers.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        Env.store.dispatch(SetNewSelectedEntry(logId: log.id,)),
        Get.toNamed(ExpenseRoutes.addEditEntries),
      },
      onLongPress: () => {
        Env.store.dispatch(SelectLog(logId: log.id)),
        Get.toNamed(ExpenseRoutes.addEditLog),
      },
    );
  }
}
