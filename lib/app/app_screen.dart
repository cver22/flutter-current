import 'package:expenses/chart/chart_ui/chart_dialog.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/store/actions/chart_actions.dart';
import '../chart/chart_model/chart_state.dart';

import '../chart/chart_ui/chart_screen.dart';

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
                      return _buildChartActions();
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
                  ChartScreen(key: ExpenseKeys.chartsScreen),
                ],
              ),
            ),
          );
        },
      ),
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
      case 'Add Log':
        Env.store.dispatch(SetNewLog());
        Get.toNamed(ExpenseRoutes.addEditLog);
        break;
    }
  }

  Widget _buildChartActions() {
    return ConnectState<ChartState>(
        where: notIdentical,
        map: (state) => state.chartState,
        builder: (state) {
          return Env.store.state.entriesState.entries.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.chartFilter.isSome)
                      _clearFilterButton(
                          action: ChartUpdateData(
                        clearFilter: true,
                        rebuildChartData: true,
                      )),
                    _filterButton(entriesChart: EntriesCharts.charts),
                    _chartSettingButton(),
                  ],
                )
              : Container();
        });
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
                    if (state.entriesFilter.isSome) _clearFilterButton(action: EntriesClearEntriesFilter()),
                    if (state.selectedEntries.isNotEmpty) _clearSelectionButton(),
                    if (state.selectedEntries.isNotEmpty) _deleteSelectionButton(),
                    _filterButton(entriesChart: EntriesCharts.entries),
                    _entriesOrder(state: state),
                    //_buildEntriesPopupMenuButton(state: state),
                  ],
                )
              : Container();
        });
  }

  Widget _clearFilterButton({required AppAction action}) {
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
        Env.store.dispatch(action);
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

  Widget _entriesOrder({required EntriesState state}) {
    return IconButton(
      icon: !state.descending ? Icon(Icons.arrow_upward_outlined) : Icon(Icons.arrow_downward_outlined),
      onPressed: () {
        Env.store.dispatch(EntriesSetOrder());
      },
    );
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

  Widget _chartSettingButton() {
    return IconButton(
      icon: Icon(Icons.tune_outlined),
      onPressed: () {
        //load adjustment dialog
        showDialog(
          context: context,
          builder: (_) => ChartDialog(),
        );
      },
    );
  }

  Widget _filterButton({required EntriesCharts entriesChart}) {
    return IconButton(
      icon: Icon(Icons.filter_alt_outlined),
      onPressed: () {
        Env.store.dispatch(FilterSetReset(entriesChart: entriesChart));
        showDialog(
          context: context,
          builder: (_) => FilterDialog(entriesChart: entriesChart),
        );
      },
    );
  }
}
