import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_ui/log_member_detailed_ui/log_member_month_list.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogListTile extends StatelessWidget {
  final Log log;

  const LogListTile({Key key, @required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int currentMonth = now.month;

    return ListTile(
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(log.name),
              IconButton(
                onPressed: () => {
                  Env.store.dispatch(SelectLog(logId: log.id)),
                  Get.toNamed(ExpenseRoutes.addEditLog),
                },
                icon: Icon(Icons.edit_outlined),
              ),
            ],
          ),
          LogMemberMonthList(log: log),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                      'Daily Average for ${MONTHS_SHORT[currentMonth - 1]}: \$ ${formattedAmount(value: log.averagePerDay, emptyReturnZeroed: true)}'),
                  Text(
                      '${MONTHS_SHORT[currentMonth - 1]} Total: \$ ${formattedAmount(value: log.thisMonthTotalPaid, emptyReturnZeroed: true)}'),
                  Text(
                      '${MONTHS_SHORT[currentMonth - 2 < 0 ? 11 : currentMonth - 2]}: \$ ${formattedAmount(value: log.lastMonthTotalPaid, emptyReturnZeroed: true)}'),
                  Text(
                      '${MONTHS_SHORT[currentMonth - 1]} ${now.year - 1}: \$ ${formattedAmount(value: log.sameMonthLastYearTotalPaid, emptyReturnZeroed: true)}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
