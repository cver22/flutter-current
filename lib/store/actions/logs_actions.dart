part of 'actions.dart';

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
  return _updateLogState(
      appState, (logsState) => logsState.copyWith(logs: cloneMap));
}

AppState _updateSingleLog(
  AppState appState,
  String logId,
  Log update(Log log),
) {
  return _updateLogs(appState, (logs) => logs..[logId] = update(logs[logId]));
}

class DeleteLog implements Action {
  final String logId;

  DeleteLog({this.logId});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleLog(
        appState, logId, (log) => log.copyWith(active: false));
  }
}

//TODO add archive field to log
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

class UpdateLog implements Action {
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
}

//TODO implement SelectLog
//TODO implement clear selection
//TODO implement setLogs to show the logs on the screen

/*class UpdateLogs extends Action {
  final List<Log> logs;

  UpdateLogs({this.logs});

  @override
  AppState updateState(AppState appState) {
    return _updateLogs(appState, (logs) {});
  }
}*/
