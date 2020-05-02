import 'package:expenses/screens/account/account_page.dart';
import 'package:flutter/material.dart';


class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          child: Text('Expense Tracker'),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  onLongPress: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (context) => AccountPage()),
                  ),
                  trailing: Icon(Icons.chevron_right),
                  title: Text('Account'),
                )
              ],
            ),
          ],
        ),
      ],
    ));
  }
}
