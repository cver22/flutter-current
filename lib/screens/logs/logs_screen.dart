import 'package:expenses/env.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/models/log/logs_state.dart';
import 'package:expenses/screens/common_widgets/empty_content.dart';
import 'package:expenses/screens/common_widgets/error_widget.dart';
import 'package:expenses/screens/common_widgets/loading_indicator.dart';
import 'package:expenses/screens/logs/log_list_tile.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({Key key}) : super(key: key);

  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
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
            return LoadingIndicator(loadingMessage: 'Loading your logs...');
          } else if (logsState.isLoading == false && logsState.logs.isNotEmpty) {
            //TODO create archive bool to show logs that have been archived and not visible
            //TODO can I move this logic to the state object and render this widget stateless?
            _logs = logsState.logs.entries.map((e) => e.value).toList();

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[buildListView(), SizedBox(height: 20.0), addLogButton(context)],
              ),
            );
          } else if (logsState.isLoading == false && logsState.logs.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    addLogButton(context),
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

  Widget buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _logs.length,
      itemBuilder: (BuildContext context, int index) {
        final Log _log = _logs[index];
        return LogListTile(log: _log);
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
        Get.toNamed(ExpenseRoutes.addEditLog),
      },
    );
  }
}
