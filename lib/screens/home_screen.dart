import 'package:expenses/env.dart';
import 'package:expenses/models/app_tab.dart';
import 'package:expenses/screens/drawer/app_drawer.dart';
import 'package:expenses/screens/entries/entries_screen.dart';
import 'package:expenses/screens/logs/logs_screen.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            LogsScreen(),
            EntriesScreen(),
            Icon(Icons.assessment),
          ],
        ),
      ),
    );
  }
}
