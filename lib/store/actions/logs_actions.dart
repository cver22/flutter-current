part of 'actions.dart';

//TODO update all actions to utilize private functions?

AppState _updateLogState(
  AppState appState,
  LogsState update(LogsState logsState),
) {
  return appState.copyWith(logsState: update(appState.logsState));
}

AppState _updateLogs(
  AppState appState,
  void updateInPlace(Map<String, Log> logs),
) {
  Map<String, Log> cloneMap = Map.from(appState.logsState.logs);
  updateInPlace(cloneMap);
  return _updateLogState(appState, (logsState) => logsState.copyWith(logs: cloneMap));
}

class SetLogsLoading implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(logsState: appState.logsState.copyWith(isLoading: true));
  }
}

class SetLogsLoaded implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(logsState: appState.logsState.copyWith(isLoading: false));
  }
}

class UpdateSelectedLog implements Action {
  final Log log;

  UpdateSelectedLog({this.log});

  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

class SelectLog implements Action {
  final String logId;

  SelectLog({this.logId});

  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(logsState.logs[logId])));
  }
}

class ClearSelectedLog implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.none()));
  }
}

class SetLogs implements Action {
  final Iterable<Log> logList;

  SetLogs({this.logList});

  @override
  AppState updateState(AppState appState) {
    return _updateLogs(appState, (logs) {
      logs.addEntries(
        logList.where((e) => e.active).map(
              (log) => MapEntry(log.id, log),
            ),
      );
    });
  }
}
//Deprecated in favour of fetcher
/*AppState _updateSingleLog(
  AppState appState,
  String logId,
  Log update(Log log),
) {
  return _updateLogs(appState, (logs) => logs..[logId] = update(logs[logId]));
}*/

/*class MarkArchiveLog implements Action {
  final String logId;
  final String archive;

  MarkArchiveLog({this.logId, this.archive});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleLog(
        appState, logId, (log) => log.copyWith(archive: !archive));
  }
}*/

//Deprecated
/*class UpdateLog implements Action {
  final String id;
  final String logName;
  final String currency;
  final List<MyCategory> categories;
  final List<MySubcategory> subcategories;
  final Map<String, dynamic> members;

  UpdateLog(
      {this.id,
      this.logName,
      this.currency,
      this.categories,
      this.subcategories,
      this.members});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleLog(
        appState,
        id,
        (log) => log.copyWith(
              id: id,
              logName: logName,
              currency: currency,
              categories: categories,
              subcategories: subcategories,
              members: members,
            ));
  }
}

class AddLog implements Action {
  final String uid;
  final String logName;
  final String currency;
  final List<MyCategory> categories;
  final List<MySubcategory> subcategories;
  final Map<String, dynamic> members;

  AddLog(
      {this.uid,
      this.logName,
      this.currency,
      this.categories,
      this.subcategories,
      this.members});

  @override
  AppState updateState(AppState appState) {
    return _updateLogs(
        appState,
        (log) => Log(
              uid: uid,
              id: Uuid().v4(),
              logName: logName,
              currency: currency,
              categories: categories,
              subcategories: subcategories,
              members: members,
            ));
  }
}*/

//Deprecated
/*class SelectLog implements Action {
  final String logId;

  SelectLog({this.logId});

  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState,
        (logsState) => logsState.copyWith(selectedLogId: Maybe.some(logId)));
  }
}

class ClearSelectedLog implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState,
        (logsState) => logsState.copyWith(selectedLogId: Maybe.none()));
  }
}*/
