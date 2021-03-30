import 'package:flutter/material.dart';

import '../../../log/log_model/log.dart';
import '../../member_model/log_member_model/log_member.dart';
import 'log_member_total_list_tile.dart';

class LogMemberTotalList extends StatelessWidget {
  final Log log;

  const LogMemberTotalList({Key key, this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<LogMember> logMembers = log.logMembers.values.toList();

    return Column(
      children: [
        Divider(height: 0.0),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: logMembers.length,
          itemBuilder: (BuildContext context, int index) {
            final LogMember member = logMembers[index];
            return LogMemberTotalListTile(member: member, log: log);
          },
        ),
      ],
    );
  }
}
