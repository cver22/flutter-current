import '../log/log_model/logs_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../entries/entries_model/entries_state.dart';
import '../entries/entries_ui/entries_screen.dart';
import '../env.dart';
import '../filter/filter_ui/filter_dialog.dart';
import '../log/log_ui/logs_screen.dart';
import '../store/actions/entries_actions.dart';
import '../store/actions/filter_actions.dart';
import '../store/actions/logs_actions.dart';
import '../store/connect_state.dart';
import '../utils/db_consts.dart';
import '../utils/expense_routes.dart';
import '../utils/keys.dart';
import '../utils/utils.dart';
import 'app_drawer.dart';
import 'common_widgets/simple_confirmation_dialog.dart';

//main screen of the app from which we can navigate to other areas of the app

class AppScreen extends StatefulWidget {
  AppScreen({Key? key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;
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
    bool logsPresent = Env.store.state.logsState.logs.isNotEmpty;

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              if (_controller.index == 0) {
                //exit app
                return true;
              } else if (_controller.index != 0) {
                //back to logs
                _controller.animateTo(0);
                return false;
              } else if (_key.currentState!.isDrawerOpen) {
                //back to logs
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
                      return _buildLogActions();
                    } else if (_controller.index == 1 && logsPresent) {
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

  PopupMenuButton<String> _buildEntriesPopupMenuButton({required EntriesState state}) {
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
          return state.entries.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.entriesFilter.isSome) _clearFilterButton(),
                    if (state.selectedEntries.isNotEmpty) _clearSelectionButton(),
                    if (state.selectedEntries.isNotEmpty) _deleteSelectionButton(),
                    _buildEntriesPopupMenuButton(state: state),
                  ],
                )
              : Container();
        });
  }

  Widget _clearFilterButton() {
    return IconButton(
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
    );
  }

  Widget _buildLogActions() {
    return ConnectState<LogsState>(
        where: notIdentical,
        map: (state) => state.logsState,
        builder: (state) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.logs.isEmpty)
                Row(
                  children: [
                    Text('Add your first log here'),
                    Icon(Icons.arrow_forward_outlined),
                  ],
                ),
              _buildLogPopupMenuButton(),
            ],
          );
        });
  }

  Widget _clearSelectionButton() {
    return IconButton(
      icon: Icon(Icons.check_outlined),
      onPressed: () {
        Env.store.dispatch(EntriesClearSelection());
      },
    );
  }

  Widget _deleteSelectionButton() {
    return IconButton(
      icon: Icon(Icons.delete_outline),
      onPressed: () async {
        await Get.dialog(
          SimpleConfirmationDialog(
            title: 'Are you sure you want to delete these entries? These cannot be recovered.',
            onTapConfirm: (confirmDelete) {
              if (confirmDelete) {
                Env.store.dispatch(EntriesDeleteSelectedEntries());
              }
            },
          ),
        );

      },
    );
  }
}
