import 'package:flutter/material.dart';

class LogMemberDetailedListTile extends StatelessWidget {
  final String name;

  const LogMemberDetailedListTile({Key key, this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(name ?? 'Please enter a name'),
    );
  }
}


//TODO - build this out with additional information such as who spent what
