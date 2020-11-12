import 'package:expenses/entry/entry_screen/entries_screen.dart';
import 'package:expenses/log/log_ui/logs_screen.dart';
import 'package:expenses/settings/settings_ui/app_drawer.dart';
import 'package:expenses/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    print('Rendering App Screen');
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
              LogsScreen(key: ExpenseKeys.logsScreen),
              EntriesScreen(key: ExpenseKeys.entriesScreen), //TODO should lead to empty content if user has not yet started a log
              Icon(Icons.assessment),
            ],
          ),
        ),
        //TODO this is an Android exit only, need iOS which is exit(0) here and in login_register_screen.dart
        onWillPop: () =>
            SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
      ),
    );
  }
}
