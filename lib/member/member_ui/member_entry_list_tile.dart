import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_model/member.dart';
import 'package:flutter/material.dart';

class MemberEntryListTile extends StatelessWidget {
  final Member member;
  final Log log;

  const MemberEntryListTile({Key key, @required this.member, @required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = log?.members[member.uid].name;

    return ListTile(leading: Text(name),
    trailing: Text('money spent or paid'),);
  }
}
