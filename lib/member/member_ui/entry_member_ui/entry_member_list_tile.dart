import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/utils/currency.dart';

import '../../../env.dart';

class EntryMemberListTile extends StatefulWidget {
  final EntryMember member;
  final String name;

  const EntryMemberListTile({Key key, @required this.member, @required this.name}) : super(key: key);

  @override
  _EntryMemberListTileState createState() => _EntryMemberListTileState();
}

class _EntryMemberListTileState extends State<EntryMemberListTile> {
  TextEditingController _paidController;
  TextEditingController _spentController;
  FocusNode _paidFocusNode;
  FocusNode _spentFocusNode;

  @override
  void initState() {
    EntryMember member = widget.member;

    _paidController = member.payingController;
    _spentController = member.spendingController;
    _paidFocusNode = member.payingFocusNode;
    _spentFocusNode = member.spendingFocusNode;

    super.initState();
  }

  @override
  void dispose() {
    _paidController.dispose();
    _spentController.dispose();
    _paidFocusNode.dispose();
    _spentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EntryMember member = widget.member;
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget?.name ?? 'Please enter a name in account'),
          // paying check box
          _buildCheckBox(
              checked: member.paying, onChanged: (value) => Env.store.dispatch(ToggleMemberPaying(member: member))),
          _buildTextFormField(
            paidOrSpent: PaidOrSpent.paid,
            controller: _paidController,
            focusNode: _paidFocusNode,
            member: member,
          ),
          // spending checkbox
          _buildCheckBox(
              checked: member.spending, onChanged: (value) => Env.store.dispatch(ToggleMemberSpending(member: member))),
          SizedBox(width: 10.0),

          _buildTextFormField(
            paidOrSpent: PaidOrSpent.spent,
            controller: _spentController,
            focusNode: _spentFocusNode,
            member: member,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(
      {PaidOrSpent paidOrSpent, TextEditingController controller, FocusNode focusNode, EntryMember member}) {
    bool isGrey = true;
    Color isGreyColor = Colors.grey[350];
    if(paidOrSpent == PaidOrSpent.paid) {
      isGrey = !member.paying;
    } else {
      isGrey = !member.spending;
    }
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('\$ ', style: TextStyle(color: isGrey ? isGreyColor : Colors.black),),
          Container(
            width: 50.0,
            child: TextFormField(
              style: TextStyle(color: isGrey ? isGreyColor : Colors.black),
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(hintText: paidOrSpent == PaidOrSpent.paid ? PAID : SPENT, hintStyle:TextStyle(color: isGrey ? isGreyColor : Colors.grey[600] ), ),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\-?\d*\.?\d{0,2}"))],
              keyboardType: TextInputType.number,
              onTap: () {
                focusNode.requestFocus();
                print('this focusNode HasFocus: ${focusNode.hasFocus}');
                print(
                    'spending focus node: ${member.spendingFocusNode.hasFocus} and paying focus node: ${member.payingFocusNode.hasFocus}');
              },
              //focus on this text field if it is tapped on
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
      ),
    );
  }

  Widget _buildCheckBox({@required bool checked, @required ValueChanged<bool> onChanged}) {
    return Expanded(
      flex: 0,
      child: Checkbox(
        value: checked,
        onChanged: onChanged,
      ),
    );
  }
}
