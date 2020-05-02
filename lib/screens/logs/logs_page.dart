import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/empty_content.dart';
import 'package:expenses/screens/logs/add_edit_log_page.dart';
import 'package:expenses/screens/logs/log_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogsBloc, LogsState>(
      // ignore: missing_return
      builder: (context, state) {
        if (state is LogsLoading) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              Text('Loading your logs...'),
            ],
          ));
        } else if (state is LogsLoaded && state.logs.isEmpty) {
          //TODO refactor later to pass both cases to a column formatted to the page
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              addLogButton(),
            ],
          );
        } else if (state is LogsLoaded) {
          //TODO upgrade to filtered logs so hide and reorganize can be utilized
          final logs = state.logs;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ListView.builder(
                  itemCount: logs.length,
                  // ignore: missing_return
                  itemBuilder: (BuildContext context, int index) {
                    final Log log = logs[index];
                    return LogListTile(
                      log: log,
                      //TODO implement onTap to log a entry/transaction
                      onLongPress: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) {
                          return AddEditLogPage(); //TODO implement an AddEditScreen
                        }),
                      ),
                    );
                  }),
              addLogButton()
            ],
          );
        } else if (state is LogsLoadFailure) {
          return Center(
              child: Column(
            children: <Widget>[
              Icon(Icons.error),
              Text('Something went wrong'),
            ],
          ));
        }
      },
    );
  }

  Widget addLogButton() {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text('Add Log'),
      elevation: 2.0,
      onPressed: () {},
    );
  }
}
