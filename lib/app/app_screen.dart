import 'package:expenses/entries/entries_screen/entries_screen.dart';
import 'package:expenses/log/log_ui/logs_screen.dart';
import 'package:expenses/settings/settings_ui/app_drawer.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../env.dart';

class AppScreen extends StatefulWidget {
  AppScreen({Key key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with SingleTickerProviderStateMixin {
  int index = 0;
  TabController _controller;
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
        print(index);
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
                    if (index == 0) {
                      bool reorder = Env.store.state.logsState.reorder;
                      return Row(children: [
                        reorder
                            ? IconButton(
                                icon: Icon(Icons.check_outlined),
                                onPressed: () => { setState((){
                                  Env.store.dispatch(Reorder(save: true));
                                }),},
                              )
                            : Container(),
                        reorder
                            ? IconButton(
                                icon: Icon(Icons.cancel_outlined),
                                onPressed: () => {
                                  setState ((){
                                    Env.store.dispatch(Reorder());
                                  }),
                                },
                              )
                            : Container(),
                        reorder ? Container() : _buildLogPopupMenuButton(reorder: reorder),
                      ]);
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
            );
          },
        ),
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

  PopupMenuButton<String> _buildLogPopupMenuButton({@required bool reorder}) {
    return PopupMenuButton<String>(
      onSelected: handleClick,
      itemBuilder: (BuildContext context) {
        Set<String> menuOptions;

        if (reorder) {
          menuOptions = {'Add Log'};
        } else {
          menuOptions = {'Add Log', 'Reorder'};
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
        Env.store.dispatch(ClearSelectedLog());
        Get.toNamed(ExpenseRoutes.addEditLog);
        break;
      case 'Reorder':
        setState(() {
          Env.store.dispatch(Reorder());
        });
        break;
    }
  }
}
