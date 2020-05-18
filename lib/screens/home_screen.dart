import 'package:expenses/screens/drawer/app_drawer.dart';
import 'package:expenses/screens/entries/entries_page.dart';
import 'package:expenses/screens/logs/logs_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: AppDrawer(),
        appBar: AppBar(
          actions: <Widget>[],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.account_balance_wallet)),
              Tab(icon: Icon(Icons.assignment)),
              Tab(icon: Icon(Icons.assessment)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LogsPage(),
            /*Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text('Welcome $name'),
                  ),
                ],
              ),*/
            EntriesPage(),
            Icon(Icons.assessment),
          ],
        ),
      ),
    );
  }
}
