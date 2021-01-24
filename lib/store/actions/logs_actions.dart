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
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    // Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);

    //check is the log currently exists
    if (addedUpdatedLog.id != null && appState.logsState.logs.containsKey(addedUpdatedLog.id)) {
      //update an existing log
      Env.logsFetcher.updateLog(addedUpdatedLog);

      //if there are new log members, add them to all transaction
      if (logs[addedUpdatedLog.id].logMembers.length != addedUpdatedLog.logMembers.length) {
        List<MyEntry> entries =
            appState.entriesState.entries.values.where((entry) => entry.logId == addedUpdatedLog.id).toList();
        Env.entriesFetcher.batchUpdateEntries(entries: entries, logMembers: addedUpdatedLog.logMembers);
      }

      logs.update(
        addedUpdatedLog.id,
        (value) => addedUpdatedLog,
        ifAbsent: () => addedUpdatedLog,
      );
    } else {
      //create a new log, does not save locally to state as there is no id yet
      Map<String, LogMember> members = {};
      String uid = appState.authState.user.value.id;
      members.putIfAbsent(
          uid, () => LogMember(uid: uid, role: OWNER, name: appState.authState.user.value.displayName, order: 0));

      addedUpdatedLog = addedUpdatedLog.copyWith(
        uid: uid,
        categories: appState.settingsState.settings.value.defaultCategories,
        subcategories: appState.settingsState.settings.value.defaultSubcategories,
        logMembers: members,
      );

      Env.logsFetcher.addLog(addedUpdatedLog);
    }

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.none(), logs: logs));
  }
}

class AddMemberToSelectedLog implements Action {
  final String uid;
  final String name;

  AddMemberToSelectedLog({this.uid, this.name});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    Map<String, LogMember> logMembers = Map.from(log.logMembers);
    //orders added log member as next in the order
    logMembers.putIfAbsent(uid, () => LogMember(uid: uid, name: name, order: logMembers.length));

    log = log.copyWith(logMembers: logMembers);

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

//used for name changes
class UpdateLogMember implements Action {
  @override
  AppState updateState(AppState appState) {
    User user = appState.authState.user.value;
    String uid = user.id;
    String displayName = user.displayName;
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    appState.logsState.logs.forEach((key, log) {
      Map<String, LogMember> logMembers = Map.from(log.logMembers);
      print('logMembers: $logMembers');
      logMembers.update(uid, (logMember) => logMember.copyWith(name: displayName));
      logs.update(key, (value) => value.copyWith(logMembers: logMembers)); //updates the log locally
      Env.logsFetcher.updateLog(logs[key]); //update log in the database
    });

    return _updateLogState(appState, (logsState) => logsState.copyWith(logs: logs));
  }
}

class AddEditCategoryFromLog implements Action {
  final MyCategory category;

  AddEditCategoryFromLog({@required this.category});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> categories = List.from(log.categories);

    if (category?.id != null) {
      //category exists, update category
      categories[categories.indexWhere((e) => e.id == category.id)] = category;
    } else {
      //category does not exists, create category
      categories.add(category.copyWith(id: Uuid().v4()));
    }

    log = log.copyWith(categories: categories);

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

class DeleteCategoryFromLog implements Action {
  final MyCategory category;

  DeleteCategoryFromLog({@required this.category});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> categories = List.from(log.categories);
    List<MyCategory> subcategories = List.from(log.subcategories);

    //remove category and its subcategories if the category is not "no category"
    if (category.id != NO_CATEGORY) {
      categories.removeWhere((e) => e.id == category.id);
      subcategories.removeWhere((e) => e.parentCategoryId == category.id);
    }

    log = log.copyWith(subcategories: subcategories, categories: categories);

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

class AddEditSubcategoryFromLog implements Action {
  final MyCategory subcategory;

  AddEditSubcategoryFromLog({@required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> subcategories = List.from(log.subcategories);

    if (subcategory?.id != null) {
      //category exists, update category
      subcategories[subcategories.indexWhere((e) => e.id == subcategory.id)] = subcategory;
    } else {
      //category does not exists, create category
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    }

    log = log.copyWith(subcategories: subcategories);

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

class DeleteSubcategoryFromLog implements Action {
  final MyCategory subcategory;

  DeleteSubcategoryFromLog({@required this.subcategory});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> subcategories = List.from(log.subcategories);

    //remove the subcategory if it is not "no subcategory"
    if (subcategory.id != NO_SUBCATEGORY) {
      subcategories.removeWhere((e) => e.id == subcategory.id);
    }

    log = log.copyWith(subcategories: subcategories);

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}
