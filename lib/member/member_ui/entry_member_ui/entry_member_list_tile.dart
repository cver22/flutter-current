import 'package:currency_picker/src/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../env.dart';
import '../../../store/actions/single_entry_actions.dart';
import '../../../currency/currency_utils/currency_formatters.dart';
import '../../../utils/db_consts.dart';
import '../../member_model/entry_member_model/entry_member.dart';

class EntryMemberListTile extends StatefulWidget {
  final EntryMember member;
  final String? name;
  final bool singleMemberLog;
  final bool autoFocus;
  final Currency? currency;

  const EntryMemberListTile(
      {Key? key,
      required this.member,
      required this.name,
      this.singleMemberLog = false,
      this.autoFocus = false,
      required this.currency})
      : super(key: key);

  @override
  _EntryMemberListTileState createState() => _EntryMemberListTileState();
}

class _EntryMemberListTileState extends State<EntryMemberListTile> {
  TextEditingController? _payingController;
  TextEditingController? _spendingController;
  FocusNode? _payingFocusNode;
  FocusNode? _spendingFocusNode;

  @override
  void initState() {
    EntryMember member = widget.member;

    _payingController = member.payingController;
    _spendingController = member.spendingController;
    _payingFocusNode = member.payingFocusNode;
    _spendingFocusNode = member.spendingFocusNode;
    if (widget.autoFocus && member.paying) {
      _payingFocusNode!.requestFocus();
    }

    super.initState();
  }

  @override
  void dispose() {
    _payingController!.dispose();
    _spendingController!.dispose();
    _payingFocusNode!.dispose();
    _spendingFocusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EntryMember member = widget.member;
    Currency currency = widget.currency!;

    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 120.0),
              child: Text(widget.name ?? 'Please enter a name in account')),
          Expanded(
            flex: 5,
            child: Container(),
          ),
          // paying check box
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckBox(
                  checked: member.paying,
                  onChanged: (value) => Env.store.dispatch(EntryToggleMemberPaying(member: member))),
              _buildTextFormField(
                currency: currency,
                paidOrSpent: PaidOrSpent.paid,
                controller: _payingController,
                focusNode: _payingFocusNode!,
                member: member,
              ),
            ],
          ),
          if (!widget.singleMemberLog)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCheckBox(
                    checked: member.spending,
                    onChanged: (value) => Env.store.dispatch(EntryToggleMemberSpending(member: member))),
                _buildTextFormField(
                  currency: currency,
                  paidOrSpent: PaidOrSpent.spent,
                  controller: _spendingController,
                  focusNode: _spendingFocusNode!,
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
      {required PaidOrSpent paidOrSpent,
      required TextEditingController? controller,
      required FocusNode focusNode,
      required EntryMember member,
      required Currency currency}) {
    bool inactive = true;
    if (paidOrSpent == PaidOrSpent.paid) {
      inactive = !member.paying;
    } else {
      inactive = !member.spending;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (currency.symbolOnLeft)
          Text(
            '${currency.symbol} ',
            style: TextStyle(color: inactive ? INACTIVE_HINT_COLOR : Colors.black),
          ),
        Container(
          width: 50.0,
          child: TextField(
            style: TextStyle(color: inactive ? INACTIVE_HINT_COLOR : Colors.black),
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: focusNode.hasFocus
                  ? ''
                  : paidOrSpent == PaidOrSpent.paid
                      ? PAID
                      : SPENT, //TODO this doesn't fully work as the initial focus does not operate
              hintStyle: TextStyle(color: inactive ? INACTIVE_HINT_COLOR : ACTIVE_HINT_COLOR),
            ),
            inputFormatters: [FilteringTextInputFormatter.allow(_getRegex(currency: currency))],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onSubmitted: (value) {
              Env.store.dispatch(EntryNextFocus(paidOrSpent: paidOrSpent));
            },
            onTap: () {
              //toggle member spending on if the the user taps in the textField
              if (paidOrSpent == PaidOrSpent.paid) {
                if (member.paying) {
                  //user already paying, update state with focus
                  Env.store.dispatch(EntryMemberFocus(paidOrSpent: paidOrSpent, memberId: member.uid));
                } else {
                  //user now paying, update focus and toggle
                  Env.store.dispatch(EntryToggleMemberPaying(member: member));
                }
              } else if (paidOrSpent == PaidOrSpent.spent) {
                if (member.spending) {
                  //user already spending, update state with focus
                  Env.store.dispatch(EntryMemberFocus(paidOrSpent: paidOrSpent, memberId: member.uid));
                } else {
                  //user now spending, update focus and toggle
                  Env.store.dispatch(EntryToggleMemberSpending(member: member));
                }
              }

              //TODO need to update state so it knows the focus location when a member tile is tapped
            },
            onChanged: (newValue) {
              int intValue = parseNewValue(newValue: newValue, currency: currency);
              if (paidOrSpent == PaidOrSpent.paid) {
                Env.store.dispatch(EntryUpdateMemberPaidAmount(paidValue: intValue, member: member));
              } else {
                Env.store.dispatch(EntryUpdateMemberSpentAmount(spentValue: intValue, member: member));
              }
            },
          ),
        ),
        if (!currency.symbolOnLeft)
          Text(
            ' ${currency.symbol}',
            style: TextStyle(color: inactive ? INACTIVE_HINT_COLOR : Colors.black),
          ),
      ],
    );
  }

  Widget _buildCheckBox({required bool? checked, required ValueChanged<bool?> onChanged}) {
    return Checkbox(
      value: checked,
      onChanged: onChanged,
    );
  }

  RegExp _getRegex({required Currency currency}) {
    if (currency.decimalDigits > 0) {
      if (currency.decimalSeparator == '.') {
        //decimal allowed
        return RegExp(r"^\-?\d*\.?\d{0,2}");
      } else if (currency.decimalSeparator == ',') {
        //comma allowed
        return RegExp(r"^\-?\d*\,?\d{0,2}");
      }
    }
    //no decimal places
    return RegExp(r"^\-?\d*");
  }
}
