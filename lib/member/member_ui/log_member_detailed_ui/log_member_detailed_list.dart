import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/member/member_ui/log_member_detailed_ui/log_member_detailed_list_tile.dart';


import 'package:flutter/material.dart';

class LogMemberDetailedList extends StatelessWidget {
  final List<LogMember> logMembers;

  const LogMemberDetailedList({Key key, this.logMembers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: logMembers.length,
        itemBuilder: (BuildContext context, int index) {
          final LogMember member = logMembers[index];
          return LogMemberDetailedListTile(name: member.name);
        },);
  }
}
