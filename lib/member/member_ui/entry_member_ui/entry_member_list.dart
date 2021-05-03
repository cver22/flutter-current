import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:flutter/material.dart';

import '../../../log/log_model/log.dart';
import '../../member_model/entry_member_model/entry_member.dart';
import 'entry_member_list_tile.dart';

class EntryMembersListView extends StatelessWidget {
  final Map<String?, EntryMember?> members;
  final Log log;
  final bool userUpdated;
  final String entryId;
  final String? currencyCode;

  const EntryMembersListView({
    Key? key,
    required this.members,
    required this.log,
    required this.userUpdated,
    required this.entryId,
    required this.currencyCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<EntryMember?> membersList = members.values.toList();

    final Currency? currency = CurrencyService().findByCode(currencyCode!);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: membersList.length,
      itemBuilder: (BuildContext context, int index) {
        final EntryMember member = membersList[index]!;
        return EntryMemberListTile(
          currency: currency,
          autoFocus: !userUpdated /*&& entryId == null*/,
          //true if new entry and not yet modified
          member: member,
          name: log.logMembers[member.uid]!.name,
          singleMemberLog: membersList.length < 2,
        );
      },
    );
  }
}
