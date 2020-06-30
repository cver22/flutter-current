import 'package:expenses/screens/drawer/app_drawer.dart';
import 'package:expenses/screens/entries/entries_screen.dart';
import 'package:expenses/screens/logs/logs_screen.dart';
import 'package:flutter/material.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
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
              LogsScreen(),
              EntriesScreen(),
              Icon(Icons.assessment),
            ],
          ),
        ),
        onWillPop: () async {
          return false;
        },
      ),
    );
  }
}
