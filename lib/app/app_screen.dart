import 'package:expenses/app/app_drawer.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entries/entries_screen/entries_screen.dart';
import 'package:expenses/filter/filter_screen/filter_dialog.dart';
import 'package:expenses/log/log_ui/logs_screen.dart';
import 'package:expenses/store/actions/entries_actions.dart';
import 'package:expenses/store/actions/filter_actions.dart';
import 'package:expenses/store/actions/logs_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/utils.dart';
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
      setState(() {});
    });
  }

  @override
  void dispose() {
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
            onWillPop: () async {
              if (_controller.index == 0) {
                return true;
              } else if (_controller.index != 0) {
                _controller.animateTo(0);
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
                    if (_controller.index == 0) {
                      return _buildLogPopupMenuButton();
                    } else if (_controller.index == 1) {
                      return _buildEntriesActions();
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
                  LogsScreen(key: ExpenseKeys.logsScreen, tabController: _controller),
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

  PopupMenuButton<String> _buildEntriesPopupMenuButton({@required EntriesState state}) {
    return PopupMenuButton<String>(
      onSelected: handleClick,
      itemBuilder: (BuildContext context) {
        Set<String> menuOptions;

        //TODO need to make this so it work with all languages
        if (state.descending) {
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
        Env.store.dispatch(FilterSetReset(entriesChart: EntriesCharts.entries));
        showDialog(
          context: context,
          builder: (_) => FilterDialog(entriesChart: EntriesCharts.entries),
        );
        break;
      case 'Ascending':
        Env.store.dispatch(EntriesSetOrder());
        break;
      case 'Descending':
        Env.store.dispatch(EntriesSetOrder());
        break;
      case 'Add Log':
        Env.store.dispatch(SetNewLog());
        Get.toNamed(ExpenseRoutes.addEditLog);
        break;
    }
  }

  Widget _buildEntriesActions() {
    return ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              state.entriesFilter.isSome
                  ? IconButton(
                      icon: Stack(
                        children: [
                          Icon(Icons.filter_alt_outlined),
                          Positioned(
                              bottom: 3.0,
                              child: Icon(
                                Icons.close_outlined,
                                color: Colors.black,
                              )),
                        ],
                      ),
                      onPressed: () {
                        Env.store.dispatch(EntriesClearEntriesFilter());
                      },
                    )
                  : Container(),
              _buildEntriesPopupMenuButton(state: state),
            ],
          );
        });
  }
}
