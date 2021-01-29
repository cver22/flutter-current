import 'package:expenses/entries/entries_screen/entries_screen.dart';
import 'package:expenses/log/log_ui/logs_screen.dart';
import 'package:expenses/settings/settings_ui/app_drawer.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../env.dart';

class AppScreen extends StatefulWidget {
  AppScreen({Key key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with SingleTickerProviderStateMixin {
  TabController _controller;
  List<Widget> tabs = [
    Tab(icon: Icon(Icons.account_balance_wallet)),
    Tab(icon: Icon(Icons.assignment)),
    Tab(icon: Icon(Icons.assessment)),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TabController(length: tabs.length, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    print('Rendering App Screen');
    return DefaultTabController(
      length: 3,
      child: WillPopScope(
        //TODO this is an Android exit only, need iOS which is exit(0) here and in login_register_screen.dart
        onWillPop: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              drawer: AppDrawer(),
              appBar: AppBar(
                actions: <Widget>[
                  Builder(builder: (BuildContext context) {
                    final index = _controller.index;

                    if (index == 0) {
                      return Container();
                    } else if (index == 1) {
                      return PopupMenuButton<String>(
                        onSelected: handleClick,
                        itemBuilder: (BuildContext context) {
                          Set<String> menuOptions;

                          //TODO need to make this so it work with all languages
                          if (Env.store.state.entriesState.descending) {
                            menuOptions = {'Filter', 'Ascending'};
                          } else {
                            menuOptions = {'Filter', 'Descending'};
                          }

                          return menuOptions.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      );

                      return IconButton(
                        icon: Icon(Icons.filter_alt_outlined),
                        onPressed: () => {},
                      );
                    } else {
                      return Container();
                    }
                  })
                ],
                bottom: TabBar(
                  controller: _controller,
                  tabs: tabs,
                ),
              ),
              body: TabBarView(
                controller: _controller,
                children: [
                  LogsScreen(key: ExpenseKeys.logsScreen),
                  EntriesScreen(key: ExpenseKeys.entriesScreen),
                  Icon(Icons.assessment),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Filter':
        //Get.dialog(widget), //TODO navigate to filter widget dialog
        break;
      case 'Ascending':
        Env.store.dispatch(SetEntriesOrder());
        break;
      case 'Descending':
        Env.store.dispatch(SetEntriesOrder());
        break;
    }
  }
}
