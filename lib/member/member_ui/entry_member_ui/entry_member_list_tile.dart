import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/store/actions/my_actions.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/utils/currency.dart';

import '../../../env.dart';

class EntryMemberListTile extends StatefulWidget {
  final EntryMember member;
  final String name;
  final bool singleMemberLog;
  final bool autoFocus;

  const EntryMemberListTile(
      {Key key, @required this.member, @required this.name, this.singleMemberLog = false, this.autoFocus = false})
      : super(key: key);

  @override
  _EntryMemberListTileState createState() => _EntryMemberListTileState();
}

class _EntryMemberListTileState extends State<EntryMemberListTile> {
  TextEditingController _payingController;
  TextEditingController _spendingController;
  FocusNode _payingFocusNode;
  FocusNode _spendingFocusNode;

  @override
  void initState() {
    EntryMember member = widget.member;

    _payingController = member.payingController;
    _spendingController = member.spendingController;
    _payingFocusNode = member.payingFocusNode;
    _spendingFocusNode = member.spendingFocusNode;
    if (widget.autoFocus && member.paying) {
      _payingFocusNode.requestFocus();
    }
    _payingFocusNode.addListener(() {
      if (!member.paying) {
        Env.store.dispatch(ToggleMemberPaying(member: member));
      }
    });
    _spendingFocusNode.addListener(() {

      if (!member.spending) {
        Env.store.dispatch(ToggleMemberSpending(member: member));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _payingController.dispose();
    _spendingController.dispose();
    _payingFocusNode.dispose();
    _spendingFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EntryMember member = widget.member;
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120.0),
              child: Text(widget?.name ?? 'Please enter a name in account')),
          Expanded(
            flex: 5,
            child: Container(),
          ),
          // paying check box
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckBox(
                  checked: member.paying, onChanged: (value) => Env.store.dispatch(ToggleMemberPaying(member: member))),
              _buildTextFormField(
                paidOrSpent: PaidOrSpent.paid,
                controller: _payingController,
                focusNode: _payingFocusNode,
                member: member,
              ),
            ],
          ),
          widget.singleMemberLog
              ? Container()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildCheckBox(
                        checked: member.spending,
                        onChanged: (value) => Env.store.dispatch(ToggleMemberSpending(member: member))),
                    _buildTextFormField(
                      paidOrSpent: PaidOrSpent.spent,
                      controller: _spendingController,
                      focusNode: _spendingFocusNode,
                      member: member,
                    ),
                  ],
                ),
          // spending checkbox
        ],
      ),
    );
  }

  Widget _buildTextFormField(
      {PaidOrSpent paidOrSpent, TextEditingController controller, FocusNode focusNode, EntryMember member}) {
    bool isGrey = true;
    Color isGreyColor = Colors.grey[350];
    if (paidOrSpent == PaidOrSpent.paid) {
      isGrey = !member.paying;
    } else {
      isGrey = !member.spending;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '\$ ',
          style: TextStyle(color: isGrey ? isGreyColor : Colors.black),
        ),
        Container(
          width: 50.0,
          child: TextFormField(
            style: TextStyle(color: isGrey ? isGreyColor : Colors.black),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: paidOrSpent == PaidOrSpent.paid ? PAID : SPENT,
              hintStyle: TextStyle(color: isGrey ? isGreyColor : Colors.grey[600]),
            ),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\-?\d*\.?\d{0,2}"))],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (value) {
              Env.store.dispatch(EntryNextFocus());
            },

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
    );
  }

  Widget _buildCheckBox({@required bool checked, @required ValueChanged<bool> onChanged}) {
    return Checkbox(
      value: checked,
      onChanged: onChanged,
    );
  }
}
