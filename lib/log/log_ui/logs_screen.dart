import 'package:drag_and_drop_lists/drag_and_drop_list.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';

import '../../app/common_widgets/empty_content.dart';
import '../../app/common_widgets/error_widget.dart';
import '../../app/common_widgets/loading_indicator.dart';
import '../../env.dart';
import '../../store/actions/logs_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/utils.dart';
import '../log_model/log.dart';
import '../log_model/logs_state.dart';
import '../log_totals_model/log_totals_state.dart';
import 'log_list_tile.dart';

class LogsScreen extends StatelessWidget {
  final TabController tabController;

  LogsScreen({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Log> logs = [];
    return ConnectState<LogTotalsState>(
        where: notIdentical,
        map: (state) => state.logTotalsState,
        builder: (logTotalsState) {
          return ConnectState<LogsState>(
              where: notIdentical,
              map: (state) => state.logsState,
              builder: (logsState) {
                print('Rendering Logs Screen');

                if (logsState.isLoading == true &&
                    Env.store.state!.singleEntryState.selectedEntry.isNone) {
                  return ModalLoadingIndicator(
                      loadingMessage: 'Loading your logs...', activate: true);
                } else if (logsState.isLoading == false &&
                    logsState.logs.isNotEmpty) {
                  //TODO create archive bool to show logs that have been archived and not visible
                  logs = logsState.logs.entries.map((e) => e.value).toList();
                  logs.sort((a, b) =>
                      a.order!.compareTo(b.order!)); //display based on order

                  return _buildReorderableList(
                      logs: logs,
                      logTotalsState: logTotalsState,
                      context: context,
                      tabController: tabController);
                } else if (logsState.isLoading == false &&
                    logsState.logs.isEmpty) {
                  return LogEmptyContent();
                } else {
                  //TODO pass meaningful error message
                  return ErrorContent();
                }
              });
        });
  }

  Widget _buildReorderableList(
      {required List<Log> logs,
      required LogTotalsState logTotalsState,
      BuildContext? context,
      required TabController tabController}) {
    //TODO need better way of handling size of reorderablelist
    return DragAndDropLists(
      onItemReorder: (oldItemIndex, oldListIndex, newItemIndex, newListIndex) {
        //unused function
      },
      onListReorder: (oldIndex, newIndex) => {
        Env.store.dispatch(
            LogReorder(oldIndex: oldIndex, newIndex: newIndex, logs: logs)),
      },
      children: List.generate(
          logs.length,
          (index) => _buildList(
              outerIndex: index,
              logs: logs,
              logTotalsState: logTotalsState,
              tabController: tabController)),
      listGhost: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 100.0),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Icon(Icons.add_box),
          ),
        ),
      ),
    );
  }

  _buildList(
      {required int outerIndex,
      required List<Log> logs,
      required LogTotalsState logTotalsState,
      required TabController tabController}) {
    Log log = logs[outerIndex];
    return DragAndDropList(
        header: LogListTile(
          key: Key(log.id),
          log: log,
          logTotal: logTotalsState.logTotals[log.id],
          tabController: tabController,
        ),
        children: [
          DragAndDropItem(child: Container()),
        ]);
  }
}
