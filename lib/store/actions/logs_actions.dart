part of 'actions.dart';

AppState _updateLogState(AppState appState,
    LogsState update(LogsState logsState),) {
  return appState.copyWith(logsState: update(appState.logsState));
}

AppState _updateLogs(AppState appState,
    void updateInPlace(Map<String, Log> logs),) {
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

class SetNewLog implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(Log(currency: 'CAD'))));
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

class NewLogSetCategories implements Action {
  final Log log;

  NewLogSetCategories({@required this.log});

  @override
  AppState updateState(AppState appState) {
    Log newLog = appState.logsState.selectedLog.value;

    newLog = newLog.copyWith(
      categories: log.categories,
      subcategories: log.subcategories,
    );

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(newLog)));
  }
}

class SelectLog implements Action {
  final String logId;

  SelectLog({this.logId});

  @override
  AppState updateState(AppState appState) {
    List<bool> expandedCategories = [];
    appState.logsState.logs[logId].categories.forEach((element) {
      expandedCategories.add(false);
    });

    return _updateLogState(
        appState,
            (logsState) =>
            logsState.copyWith(selectedLog: Maybe.some(logsState.logs[logId]), expandedCategories: expandedCategories));
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

class CanReorder implements Action {
  final bool save;

  CanReorder({this.save = false});

  @override
  AppState updateState(AppState appState) {
    bool reorder = appState.logsState.reorder;

    if (reorder && save) {
      //app is in reorder state and user wishes to save
      appState.logsState.logs.forEach((key, log) {
        Env.logsFetcher.updateLog(log);
      });
    } else if (reorder && !save) {
      //app is in reorder state and user does not wish to save, reload previous logs
      Env.logsFetcher.loadLogs();
    }

    return _updateLogState(appState, (logsState) => logsState.copyWith(reorder: !reorder));
  }
}

class ReorderLog implements Action {
  final int oldIndex;
  final int newIndex;
  final List<Log> logs;

  ReorderLog({this.oldIndex, this.newIndex, this.logs});

  @override
  AppState updateState(AppState appState) {
    Map<String, Log> logsMap = Map.from(appState.logsState.logs);
    List<Log> organizedLogs = logs;

    Log movedLog = organizedLogs.removeAt(oldIndex);
    organizedLogs.insert(newIndex, movedLog);

    organizedLogs.forEach((log) {
      logsMap[log.id] = log.copyWith(order: organizedLogs.indexOf(log));
    });

    return _updateLogState(appState, (logsState) => logsState.copyWith(logs: logsMap));
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
      int order = 0;

      if (logs.length > 0) {
        logs.forEach((key, log) {
          if (log.order > order) {
            order = log.order;
          }
        });
        order++;
      }

      members.putIfAbsent(
          uid, () => LogMember(uid: uid, role: OWNER, name: appState.authState.user.value.displayName, order: 0));

      addedUpdatedLog = addedUpdatedLog.copyWith(
        uid: uid,
        logMembers: members,
        order: order,
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
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);

    if (category?.id != null) {
      //category exists, update category
      categories[categories.indexWhere((e) => e.id == category.id)] = category;
    } else {
      //category does not exists, create category
      categories.add(category.copyWith(id: Uuid().v4()));
      expandedCategories.add(false);
    }

    log = log.copyWith(categories: categories);

    return _updateLogState(appState,
            (logsState) => logsState.copyWith(selectedLog: Maybe.some(log), expandedCategories: expandedCategories));
  }
}

class DeleteCategoryFromLog implements Action {
  final MyCategory category;

  DeleteCategoryFromLog({@required this.category});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> categories = List.from(log.categories);
    List<MyCategory> subcategories = List.from(log.subcategories);
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    bool canDeleteCategory = _canDeleteCategory(id: category.id);

    //remove category and its subcategories if the category is not "no category"
    if (canDeleteCategory) {
      int indexOfCategory = categories.indexWhere((element) => element.id == category.id);
      categories.removeAt(indexOfCategory);
      subcategories.removeWhere((e) => e.parentCategoryId == category.id);
      expandedCategories.removeAt(indexOfCategory);
    }

    log = log.copyWith(subcategories: subcategories, categories: categories);

    return _updateLogState(appState,
            (logsState) => logsState.copyWith(selectedLog: Maybe.some(log), expandedCategories: expandedCategories));
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
    bool canDeleteSubcategory = _canDeleteSubcategory(subcategory: subcategory);

    if (canDeleteSubcategory) {
      subcategories.removeWhere((e) => e.id == subcategory.id);
      log = log.copyWith(subcategories: subcategories);
    }

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

class ExpandCollapseLogCategory implements Action {
  final int index;

  ExpandCollapseLogCategory({@required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return _updateLogState(appState, (logsState) => logsState.copyWith(expandedCategories: expandedCategories));
  }
}

class ReorderCategoryFromLogScreen implements Action {
  final int oldCategoryIndex;
  final int newCategoryIndex;

  ReorderCategoryFromLogScreen({@required this.oldCategoryIndex, @required this.newCategoryIndex});

  AppState updateState(AppState appState) {
    //reorder categories
    List<MyCategory> categories = List.from(appState.logsState.selectedLog.value.categories);
    MyCategory movedCategory = categories.removeAt(oldCategoryIndex);
    categories.insert(newCategoryIndex, movedCategory);

    //reorder expanded list
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    bool movedExpansion = expandedCategories.removeAt(oldCategoryIndex);
    expandedCategories.insert(newCategoryIndex, movedExpansion);

    return _updateLogState(
        appState,
            (logsState) =>
            logsState.copyWith(
                selectedLog: Maybe.some(appState.logsState.selectedLog.value.copyWith(categories: categories)),
                expandedCategories: expandedCategories));
  }
}

class ReorderSubcategoryFromLogScreen implements Action {
  final int oldCategoryIndex;
  final int newCategoryIndex;
  final int oldSubcategoryIndex;
  final int newSubcategoryIndex;

  ReorderSubcategoryFromLogScreen({@required this.oldCategoryIndex,
    @required this.newCategoryIndex,
    @required this.oldSubcategoryIndex,
    @required this.newSubcategoryIndex});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    String oldParentId = log.categories[oldCategoryIndex].id;
    String newParentId = log.categories[newCategoryIndex].id;
    List<MyCategory> subcategories = List.from(log.subcategories);
    List<MyCategory> subsetOfSubcategories = List.from(subcategories);
    subsetOfSubcategories
        .retainWhere((subcategory) => subcategory.parentCategoryId == oldParentId); //get initial subset
    MyCategory subcategory = subsetOfSubcategories[oldSubcategoryIndex];

    //NO_SUBCATEGORY cannot be altered and no subcategories may be moved to NO_CATEGORY
    if (_canReorderSubcategory(subcategory: subcategory, newParentId: newParentId)) {
      if (oldParentId == newParentId) {
        //subcategory has not moved parents
        subsetOfSubcategories.remove(subcategory);
        subsetOfSubcategories.insert(newSubcategoryIndex, subcategory);
      } else {
        //category has moved parents, organize in new list with revised parent
        subsetOfSubcategories = List.from(subcategories); //reinitialize subset list
        subsetOfSubcategories.retainWhere((subcategory) => subcategory.parentCategoryId == newParentId);
        subsetOfSubcategories.insert(newSubcategoryIndex, subcategory.copyWith(parentCategoryId: newParentId));
      }

      //remove from subcategory list
      subsetOfSubcategories.forEach((reordedSub) {
        subcategories.removeWhere((sub) => reordedSub.id == sub.id);
      });
      //reinsert in subcategory list in revised order
      subsetOfSubcategories.forEach((subcategory) {
        subcategories.add(subcategory);
      });
    }

    return _updateLogState(
        appState,
            (logsState) =>
            logsState.copyWith(
                selectedLog: Maybe.some(appState.logsState.selectedLog.value.copyWith(subcategories: subcategories))));
  }
}
