import 'package:flutter/material.dart';

class LogMemberListTile extends StatelessWidget {
  final String name;

  const LogMemberListTile({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(name),
    );
  }
}
