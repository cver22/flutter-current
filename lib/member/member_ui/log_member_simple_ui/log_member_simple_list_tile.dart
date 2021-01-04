import 'package:flutter/material.dart';

class LogMemberSimpleListTile extends StatelessWidget {
  final String name;

  const LogMemberSimpleListTile({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(name ?? 'Please enter a name'),
    );
  }
}
