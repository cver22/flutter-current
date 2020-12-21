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
  return _updateLogState(appState, (logsState) => logsState.copyWith(logs: cloneMap));
}

class SetLogsLoading implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(isLoading: true));
  }
}

class SetLogsLoaded implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(isLoading: false));
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
        logList.map(
          (log) => MapEntry(log.id, log),
        ),
      );
    });
  }
}

class AddUpdateLog implements Action {
  AppState updateState(AppState appState) {
    Log addedUpdatedLog = appState.logsState.selectedLog.value;
    LogsState logsState = appState.logsState;

    //check is the log currently exists
    if (addedUpdatedLog.id != null && appState.logsState.logs.containsKey(addedUpdatedLog.id)) {
      //update an existing log
      Env.logsFetcher.updateLog(addedUpdatedLog);

      logsState.logs.update(
        addedUpdatedLog.id,
        (value) => addedUpdatedLog,
        ifAbsent: () => addedUpdatedLog,
      );
    } else {
      //create a new log, does not save locally to state as there is no id yet
      Map<String, LogMember> members = {};
      String uid = appState.authState.user.value.id;
      members.putIfAbsent(uid, () => LogMember(uid: uid, role: OWNER, name: appState.authState.user.value.displayName));

      addedUpdatedLog = addedUpdatedLog.copyWith(
        uid: uid,
        categories: appState.settingsState.settings.value.defaultCategories,
        subcategories: appState.settingsState.settings.value.defaultSubcategories,
        logMembers: members,
      );

      Env.logsFetcher.addLog(addedUpdatedLog);

      //TODO, does not update the state locally for new logs, may want to consider that, lst time I ended up with temporary duplicates
    }

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.none()));
  }
}

class DeleteLog implements Action {
  final Log log;

  DeleteLog({this.log});

  @override
  AppState updateState(AppState appState) {
    LogsState updatedLogsState = appState.logsState;
    updatedLogsState.logs.removeWhere((key, value) => key == log.id);

    //TODO this may not be a legal action, not sure if I can trigger an acting within an action
    //ensures the default log is updated if the current log is default and deleted
    if (appState.settingsState.settings.value.defaultLogId == log.id && updatedLogsState.logs.isNotEmpty) {
      Env.store.dispatch(UpdateSettings(
          settings: Maybe.some(appState.settingsState.settings.value
              .copyWith(defaultLogId: updatedLogsState.logs.values.firstWhere((element) => element.id != log.id).id))));
    }

    //TODO likely need a method to reset the default to nothing, else statement for the above
    Env.logsFetcher.deleteLog(log);

    //TODO refer to tag and entry lists to batch delete all of them

    return _updateLogState(appState, (logsState) => updatedLogsState.copyWith(selectedLog: Maybe.none()));
  }
}
