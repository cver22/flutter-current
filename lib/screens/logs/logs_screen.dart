import 'package:expenses/env.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/models/log/logs_state.dart';
import 'package:expenses/screens/common_widgets/empty_content.dart';
import 'package:expenses/screens/logs/log_list_tile.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

class LogsScreen extends StatelessWidget {
  //TODO LogsBloc _logsBloc; and how to dispose
  List<Log> _logs = [];

  @override
  Widget build(BuildContext context) {
    Env.logsFetcher.loadLogs();
    return ConnectState<LogsState>(
        where: notIdentical,
        map: (state) => state.logsState,
        builder: (logsState) {
          print('Rendering Logs Screen');
          print(logsState.toString());
          if (logsState.isLoading == true) {
            return logsLoading();
          } else if (logsState.isLoading == false &&
              logsState.logs.isNotEmpty) {
            //Only shows logs that have not been "deleted"
            //TODO create archive bool to show logs that have been archived and not visible
            _logs = logsState.logs.entries
                .map((e) => e.value)
                .where((e) => e.active == true)
                .toList();

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildListView(),
                  SizedBox(height: 20.0),
                  addLogButton(context)
                ],
              ),
            );
          } else if (logsState.isLoading == false && logsState.logs.isEmpty) {
            return EmptyContent();
          } else {
            return errorWidget();
          }
        });
  }

  Widget errorWidget() {
    return Center(
              child: Column(
            children: <Widget>[
              Icon(Icons.error),
              Text('Something went wrong'),
            ],
          ));
  }

  Widget logsLoading() {
    return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Text('Loading your logs...'),
            ],
          ));
  }

  Widget buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _logs.length,
      // ignore: missing_return
      itemBuilder: (BuildContext context, int index) {
        final Log _log = _logs[index];
        return LogListTile(
          log: _log,
          onTap: () => {
            Env.store.dispatch(SelectLog(logId: _log.id)),
          }, //TODO route to entry page
          onLongPress: () => {
            Env.store.dispatch(SelectLog(logId: _log.id)),
            Navigator.pushNamed(context, ExpenseRoutes.addEditLog),

          },
        );
      },
    );
  }

  Widget addLogButton(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text('Add Log'),
      elevation: 2.0,
      onPressed: () => {
        Navigator.pushNamed(context, ExpenseRoutes.addEditLog),
      }, //TODO Navigate to add edit log page
    );
  }
}
