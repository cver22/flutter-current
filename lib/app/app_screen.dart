import 'package:expenses/app/app_drawer.dart';
import 'package:expenses/entries/entries_screen/entries_screen.dart';
import 'package:expenses/log/log_ui/logs_screen.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../env.dart';

//main screen of the app from which we can navigate to other options of the app

class AppScreen extends StatefulWidget {
  AppScreen({Key key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with SingleTickerProviderStateMixin {
  int index = 0;
  TabController _controller;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  List<Widget> tabs = [
    Tab(icon: Icon(Icons.account_balance_wallet)),
    Tab(icon: Icon(Icons.assignment)),
    Tab(icon: Icon(Icons.assessment)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: tabs.length, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      setState(() {
        index = _controller.index;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Rendering App Screen');
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (BuildContext context) {
          return WillPopScope(
            //TODO this works the first time but does not work when the app comes back from sleeping
            onWillPop: () async {
              if (index == 0) {
                return true;
              } else if (index != 0) {
                setState(() {
                  _controller.animateTo(0);
                });
                return false;
              } else if (_key.currentState.isDrawerOpen) {
                Navigator.of(context).pop();
                return false;
              }
              return true;
            },
            child: Scaffold(
              drawer: AppDrawer(),
              appBar: AppBar(
                actions: <Widget>[
                  Builder(builder: (BuildContext context) {
                    if (index == 0) {
                      return _buildLogPopupMenuButton();
                    } else if (index == 1) {
                      return _buildEntriesPopupMenuButton();
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
            ),
          );
        },
      ),
    );
  }

  PopupMenuButton<String> _buildEntriesPopupMenuButton() {
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
  }

  PopupMenuButton<String> _buildLogPopupMenuButton() {
    return PopupMenuButton<String>(
      onSelected: handleClick,
      itemBuilder: (BuildContext context) {
        Set<String> menuOptions = {'Add Log'};

        return menuOptions.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
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
      case 'Add Log':
        Env.store.dispatch(SetNewLog());
        Get.toNamed(ExpenseRoutes.addEditLog);
        break;
      case 'Reorder':
        setState(() {
          Env.store.dispatch(CanReorder());
        });
        break;
    }
  }
}
