import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_totals_model/log_total.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/member/member_ui/log_member_detailed_ui/log_member_month_list_tile.dart';
import 'package:flutter/material.dart';

class LogMemberMonthList extends StatelessWidget {
  final Log log;
  final LogTotal logTotal;

  const LogMemberMonthList({Key key, @required this.log, @required this.logTotal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<LogMember> logMembers = logTotal?.logMembers?.values?.toList() ?? log.logMembers.values.toList();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: logMembers.length,
      itemBuilder: (BuildContext context, int index) {
        final LogMember member = logMembers[index];
        return LogMemberMonthListTile(member: member, log: log, singleMemberLog: logMembers.length < 2,);
      },
    );
  }
}
