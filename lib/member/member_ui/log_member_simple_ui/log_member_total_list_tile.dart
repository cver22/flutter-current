import 'package:flutter/material.dart';

class LogMemberTotalListTile extends StatelessWidget {
  final String name;

  const LogMemberTotalListTile({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
      title: Row(
        children: [
          Text(name ?? 'Please enter a name'),
        ],
      ),
    );
  }
}
