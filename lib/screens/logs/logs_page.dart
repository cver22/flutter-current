import 'package:expenses/blocs/entries_bloc/entries_bloc.dart';
import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/empty_content.dart';
import 'package:expenses/screens/entries/add_edit_entries_page.dart';
import 'package:expenses/screens/logs/add_edit_log_page.dart';
import 'package:expenses/screens/logs/log_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class LogsPage extends StatelessWidget {
  //TODO LogsBloc _logsBloc; and how to dispose

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogsBloc, LogsState>(
      // ignore: missing_return
      builder: (context, state) {
        //TODO _logsBloc = BlocProvider.of<LogsBloc>(context);
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
          final _logs = state.logs;
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _logs.isEmpty
                    ? EmptyContent() //TODO need to center this
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _logs.length,
                        // ignore: missing_return
                        itemBuilder: (BuildContext context, int index) {
                          final Log _log = _logs[index];
                          //Only shows logs that have not been "deleted"
                          if (_log.active == true) {
                            return LogListTile(
                              log: _log,
                              //TODO do I need to pas the logs bloc?
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) {
                                  return BlocProvider.value(
                                    value:
                                        BlocProvider.of<EntriesBloc>(context),
                                    child: BlocProvider.value(
                                      value: BlocProvider.of<LogsBloc>(context),
                                      child: AddEditEntriesPage(log: _log),
                                    ),
                                  );
                                }),
                              ),
                              onLongPress: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) {
                                  return BlocProvider.value(
                                    value: BlocProvider.of<LogsBloc>(context),
                                    child: AddEditLogPage(log: _log),
                                  );
                                }),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                SizedBox(height: 20.0),
                addLogButton(context)
              ],
            ),
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
        MaterialPageRoute(builder: (_) {
          return BlocProvider.value(
            value: BlocProvider.of<LogsBloc>(context),
            child: AddEditLogPage(),
          );
        }),
      ),
    );
  }
}
