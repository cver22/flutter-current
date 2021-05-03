import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../env.dart';
import '../../../log/log_model/log.dart';
import '../../../store/actions/single_entry_actions.dart';
import '../../../currency/currency_utils/currency_formatters.dart';
import '../../../utils/expense_routes.dart';
import '../../member_model/log_member_model/log_member.dart';

class LogMemberMonthListTile extends StatelessWidget {
  final LogMember member;
  final Log log;
  final bool singleMemberLog;

  const LogMemberMonthListTile(
      {Key? key,
      required this.log,
      required this.member,
      this.singleMemberLog = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Currency currency = CurrencyService().findByCode(log.currency!)!;

    return Column(
      children: [
        ListTile(
          onTap: () => {
            Env.store.dispatch(EntrySetNew(
              logId: log.id,
              memberId: member.uid,
            )),
            Get.toNamed(ExpenseRoutes.addEditEntries),
          },
          contentPadding:
              EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(member.name ?? 'Please enter a name'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      'Paid: ${formattedAmount(value: member.paid, showTrailingZeros: true, showSymbol: true, currency: currency)}'),
                  singleMemberLog
                      ? Container()
                      : Text(
                          '  Spent: ${formattedAmount(value: member.spent, showTrailingZeros: true, showSymbol: true, currency: currency)}'),
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
