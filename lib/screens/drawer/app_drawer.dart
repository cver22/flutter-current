import 'package:expenses/screens/account/account_page.dart';
import 'package:expenses/screens/setting/settings_page.dart';
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
                DrawerListTile(page: SettingsPage(), name: 'Settings'),
                DrawerListTile(page: AccountPage(), name: 'Account'),
              ],
            ),
          ],
        ),
      ],
    ));
  }
}

class DrawerListTile extends StatelessWidget {
  final Widget page;
  final String name;

  const DrawerListTile({
    this.page,
    this.name,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => page)),
      trailing: Icon(Icons.chevron_right),
      title: Text(name),
    );
  }
}
