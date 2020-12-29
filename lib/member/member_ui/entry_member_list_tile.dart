import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/utils/currency.dart';

import '../../env.dart';

class EntryMemberListTile extends StatelessWidget {
  final EntryMember member;
  final String name;
  final PaidOrSpent paidOrSpent;

  const EntryMemberListTile({Key key, @required this.member, @required this.name, @required this.paidOrSpent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int value = paidOrSpent == PaidOrSpent.paid ? member.paid : member.spent;

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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              child: Text('\$'),
            ),
            Container(
              width: 50.0,
              child: TextFormField(
                decoration: InputDecoration(hintText: paidOrSpent == PaidOrSpent.paid ? PAID : SPENT),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d{0,2}"))],
                initialValue: formattedAmount(value: value) ?? '',
                keyboardType: TextInputType.number,
                onChanged: (newValue) {
                  int intValue = parseNewValue(newValue: newValue);
                  if (paidOrSpent == PaidOrSpent.paid) {
                    Env.store.dispatch(UpdateMemberPaidAmount(paidValue: intValue, member: member));
                  } else {
                    Env.store.dispatch(UpdateMemberSpentAmount(spentValue: intValue, member: member));
                  }
                },
              ),
            ),
          ],
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
