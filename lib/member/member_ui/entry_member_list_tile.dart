
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';

class EntryMemberListTile extends StatelessWidget {
  final EntryMember member;
  final String name;
  final PaidOrSpent paidOrSpent;

  const EntryMemberListTile({Key key, @required this.member, @required this.name, @required this.paidOrSpent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double value = paidOrSpent == PaidOrSpent.paid ? member.paid : member.spent;

    return ListTile(
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            paidOrSpent == PaidOrSpent.paid
                ? _buildPayingCheckbox(member: member)
                : _buildSpendingCheckbox(member: member),
            SizedBox(width: 10.0),
            Text(name),
          ],
        ),
        trailing: TextFormField(
          decoration: InputDecoration(hintText: paidOrSpent == PaidOrSpent.paid ? PAID : SPENT),
          //TODO how to limit to 2 decimal places and only 1 decimal
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*"))],
          initialValue: value.toStringAsFixed(2) ?? null,
          keyboardType: TextInputType.number,
          onChanged: (value) => {
            if (paidOrSpent == PaidOrSpent.paid)
              {
                Env.store.dispatch(UpdateMemberPaidAmount(paidValue: double.parse(value), member: member)),
              }
            else
              {
                Env.store.dispatch(UpdateMemberSpentAmount(spentValue: double.parse(value), member: member)),
              }
          },
        ));
  }

  Checkbox _buildPayingCheckbox({@required EntryMember member}) {
    return Checkbox(
      value: member.paying,
      onChanged: (bool value) {
        Env.store.dispatch(ToggleMemberPaying(member: member));
      },
    );
  }

  Checkbox _buildSpendingCheckbox({@required EntryMember member}) {
    return Checkbox(
      value: member.paying,
      onChanged: (bool value) {
        Env.store.dispatch(ToggleMemberSpending(member: member));
      },
    );
  }
}
