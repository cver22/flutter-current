import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogMemberMonthListTile extends StatelessWidget {
  final LogMember member;
  final Log log;

  const LogMemberMonthListTile({Key key, @required this.log, @required this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () =>
        {
          Env.store.dispatch(SetNewSelectedEntry(
            logId: log.id,
            memberId: member.uid,
          )),
          Get.toNamed(ExpenseRoutes.addEditEntries),
        },
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(member.name ?? 'Please enter a name'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Paid: \$ ${formattedAmount(value: member.paid, emptyReturnZeroed: true)}  '),
              Text('Spent: \$ ${formattedAmount(value: member.spent, emptyReturnZeroed: true)}'),
            ],
          )
        ],
      ),
    );
  }
}

//TODO - build this out with additional information such as who spent what
