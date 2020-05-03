import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/log/log.dart';
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
        } else if (state is LogsLoaded) {
          //TODO upgrade to filtered logs so hide and reorganize can be utilized
          final logs = state.logs;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              state.logs.isEmpty
                  ? Container()
                  : ListView.builder(
                      itemCount: logs.length,
                      // ignore: missing_return
                      itemBuilder: (BuildContext context, int index) {
                        final Log log = logs[index];
                        return LogListTile(
                          log: log,
                          //TODO implement onTap to log a entry/transaction
                          onTap: () {},
                          onLongPress: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return AddEditLogPage(log: log); //TODO implement an AddEditScreen
                            }),
                          ),
                        );
                      }),
              SizedBox(height: 20.0),
              addLogButton(context)
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

  Widget addLogButton(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Text('Add Log'),
      elevation: 2.0,
      onPressed: () => Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return AddEditLogPage();
      }),
    ),);
  }
}
