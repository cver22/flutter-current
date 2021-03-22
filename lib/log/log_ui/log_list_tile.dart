import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';
import '../../member/member_ui/log_member_detailed_ui/log_member_month_list.dart';
import '../../store/actions/entries_actions.dart';
import '../../store/actions/logs_actions.dart';
import '../../utils/currency.dart';
import '../../utils/db_consts.dart';
import '../../utils/expense_routes.dart';
import '../log_model/log.dart';
import '../log_totals_model/log_total.dart';

class LogListTile extends StatelessWidget {
  final Log log;
  final LogTotal logTotal;
  final TabController tabController;

  const LogListTile(
      {Key key,
      @required this.log,
      @required this.logTotal,
      @required this.tabController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int currentMonth = now.month;

    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(log.name),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Env.store
                            .dispatch(EntriesSetEntriesFilter(logId: log.id));
                        tabController.animateTo(1);
                      },
                      icon: Icon(Icons.assignment_outlined),
                    ),
                    IconButton(
                      onPressed: () {
                        tabController.animateTo(2);
                      },
                      icon: Icon(Icons.assessment_outlined),
                    ),
                    IconButton(
                      onPressed: () {
                        Env.store.dispatch(LogSelectLog(logId: log.id));
                        Get.toNamed(ExpenseRoutes.addEditLog);
                      },
                      icon: Icon(Icons.info_outline),
                    ),
                  ],
                ),
              ],
            ),
            Divider(height: 0.0),
            LogMemberMonthList(log: log, logTotal: logTotal),
            SizedBox(height: 10.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        '${MONTHS_SHORT[currentMonth - 1]} Daily Average: \$ ${formattedAmount(value: logTotal?.averagePerDay, emptyReturnZeroed: true)}'),
                    Text(
                        '${MONTHS_SHORT[currentMonth - 1]} Total: \$ ${formattedAmount(value: logTotal?.thisMonthTotalPaid, emptyReturnZeroed: true)}'),
                    Text(
                        '${MONTHS_SHORT[currentMonth - 2 < 0 ? 11 : currentMonth - 2]}: \$ ${formattedAmount(value: logTotal?.lastMonthTotalPaid, emptyReturnZeroed: true)}'),
                    Text(
                        '${MONTHS_SHORT[currentMonth - 1]} ${now.year - 1}: \$ ${formattedAmount(value: logTotal?.sameMonthLastYearTotalPaid, emptyReturnZeroed: true)}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
