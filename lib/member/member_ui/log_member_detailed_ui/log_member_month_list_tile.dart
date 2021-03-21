import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogMemberMonthListTile extends StatelessWidget {
  final LogMember member;
  final Log log;
  final bool singleMemberLog;

  const LogMemberMonthListTile({Key key, @required this.log, @required this.member, this.singleMemberLog = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () => {
            Env.store.dispatch(EntrySetNewSelect(
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
                  Text('Paid: \$ ${formattedAmount(value: member.paid, emptyReturnZeroed: true)}'),
                  singleMemberLog
                      ? Container()
                      : Text('  Spent: \$ ${formattedAmount(value: member.spent, emptyReturnZeroed: true)}'),
                ],
              )
            ],
          ),
        ),
        Divider(height: 0.0),
      ],
    );
  }
}

//TODO - build this out with additional information such as who spent what
