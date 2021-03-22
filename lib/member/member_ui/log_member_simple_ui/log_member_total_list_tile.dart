import 'package:flutter/material.dart';

import '../../../env.dart';
import '../../../utils/currency.dart';
import '../../member_model/log_member_model/log_member.dart';

class LogMemberTotalListTile extends StatelessWidget {
  final LogMember member;
  final String logId;

  const LogMemberTotalListTile({Key key, this.member, this.logId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name ?? 'Please enter a name'),
              _totals(member: member, logId: logId),
            ],
          ),
        ),
        Divider(height: 0.0),
      ],
    );
  }
}

Widget _totals({@required LogMember member, @required String logId}) {
  int paid = 0;
  int spent = 0;
  int owed = 0;

  Env.store.state.entriesState.entries.values
      .where((entry) => entry.logId == logId)
      .forEach((element) {
    paid += element.entryMembers[member.uid]?.paid ?? 0;
    spent += element.entryMembers[member.uid]?.spent ?? 0;
  });

  owed = paid - spent;

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text('Paid: \$ ${formattedAmount(value: paid, emptyReturnZeroed: true)}'),
      Text(
          'Spent: \$ ${formattedAmount(value: spent, emptyReturnZeroed: true)}'),
      Text(
          '${owed > 0 ? 'Owed' : 'Owes'}:  \$ ${formattedAmount(value: owed.abs(), emptyReturnZeroed: true)}'),
    ],
  );
}
