import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/log/log_ui/log_list_tile.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogsScreen extends StatelessWidget {
  LogsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Log> _logs = [];
    return ConnectState<LogsState>(
        where: notIdentical,
        map: (state) => state.logsState,
        builder: (logsState) {
          print('Rendering Logs Screen');
          logsState.logs.values.forEach((element) {
            print('Log name ${element.logName} is active: ${element.active}');
          });

          if (logsState.isLoading == true && Env.store.state.entryState.selectedEntry.isNone) {
            return LoadingIndicator(loadingMessage: 'Loading your logs...');
          } else if (logsState.isLoading == false && logsState.logs.isNotEmpty) {
            //TODO create archive bool to show logs that have been archived and not visible
            //TODO can I move this logic to the state object and render this widget stateless?
            _logs = logsState.logs.entries.map((e) => e.value).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildListView(_logs),
                  SizedBox(height: 20.0),
                  addLogButton(context: context, logsState: logsState),
                ],
              ),
            );
          } else if (logsState.isLoading == false && logsState.logs.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    addLogButton(context: context, logsState: logsState),
                    SizedBox(height: 20.0),
                    EmptyContent(),
                  ]),
            );
          } else {
            //TODO pass meaningful error message
            return ErrorContent();
          }
        });
  }

  Widget buildListView(List<Log> _logs) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _logs.length,
      itemBuilder: (BuildContext context, int index) {
        final Log _log = _logs[index];
        return LogListTile(log: _log);
      },
    );
  }

  Widget addLogButton({BuildContext context, LogsState logsState}) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text('Add Log'),
      elevation: 2.0,
      onPressed: () => {
        Env.store.dispatch(ClearSelectedLog()),
        Get.toNamed(ExpenseRoutes.addEditLog),
      },
    );
  }
}
