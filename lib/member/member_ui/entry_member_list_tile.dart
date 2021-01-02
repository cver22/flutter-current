import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/utils/currency.dart';

import '../../env.dart';

class EntryMemberListTile extends StatefulWidget {
  final EntryMember member;
  final String name;
  final PaidOrSpent paidOrSpent;

  const EntryMemberListTile({Key key, @required this.member, @required this.name, @required this.paidOrSpent})
      : super(key: key);

  @override
  _EntryMemberListTileState createState() => _EntryMemberListTileState();
}

class _EntryMemberListTileState extends State<EntryMemberListTile> {
  TextEditingController _controller;
  FocusNode _focusNode;

  @override
  void initState() {
    EntryMember member = widget.member;

    if (widget.paidOrSpent == PaidOrSpent.paid) {
      _controller = member.payingController;
      _focusNode = member.payingFocusNode;
    } else {
      _controller = member.spendingController;
      _focusNode = member.spendingFocusNode;
    }

    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.paidOrSpent == PaidOrSpent.paid
                ? _buildPayingCheckbox(member: widget.member)
                : _buildSpendingCheckbox(member: widget.member),
            SizedBox(width: 10.0),
            Text(widget.name),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\$ '),
            Container(
              width: 80.0,
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(hintText: widget.paidOrSpent == PaidOrSpent.paid ? PAID : SPENT),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\-?\d*\.?\d{0,2}"))],
                keyboardType: TextInputType.number,
                onTap: () {
                  _focusNode.requestFocus();
                  print(
                      'spending focus node: ${widget.member.spendingFocusNode.hasFocus} and paying focus node: ${widget.member.payingFocusNode.hasFocus}');
                },
                //focus on this text field if it is tapped on
                onChanged: (newValue) {
                  int intValue = parseNewValue(newValue: newValue);
                  if (widget.paidOrSpent == PaidOrSpent.paid) {
                    Env.store.dispatch(UpdateMemberPaidAmount(paidValue: intValue, member: widget.member));
                  } else {
                    Env.store.dispatch(UpdateMemberSpentAmount(spentValue: intValue, member: widget.member));
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
      value: member.spending,
      onChanged: (bool value) {
        Env.store.dispatch(ToggleMemberSpending(member: member));
      },
    );
  }
}
