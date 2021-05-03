import 'package:uuid/uuid.dart';

import '../../app/models/app_state.dart';
import '../../auth_user/models/app_user.dart';
import '../../categories/categories_model/app_category/app_category.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../entry/entry_model/single_entry_state.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../log/log_model/logs_state.dart';
import '../../member/member_model/log_member_model/log_member.dart';
import '../../settings/settings_model/settings.dart';
import '../../tags/tag_model/tag.dart';
import '../../utils/db_consts.dart';
import '../../utils/maybe.dart';
import 'app_actions.dart';


AppState _updateLogs(
  AppState appState,
  void updateInPlace(Map<String, Log> logs),
) {
  Map<String, Log> cloneMap = Map.from(appState.logsState.logs);
  updateInPlace(cloneMap);

  return updateSubstates(
    appState,
    [
      updateLogsState((logsState) => logsState.copyWith(logs: cloneMap)),
    ],
  );
}

class SetLogsLoading implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(isLoading: true)),
      ],
    );
  }
}

class SetLogsLoaded implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(isLoading: false)),
      ],
    );
  }
}

class SetNewLog implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(selectedLog: Maybe<Log>.some(Log(currency: 'CAD', uid: appState.authState.user.value.id)))),
      ],
    );
  }
}

class UpdateSelectedLog implements AppAction {
  final Log log;

  UpdateSelectedLog({required this.log});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(selectedLog: Maybe<Log>.some(log), userUpdated: true)),
      ],
    );
  }
}

class LogUpdateName implements AppAction {
  final String name;

  LogUpdateName({required this.name});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    bool canSave = false;
    log = log.copyWith(name: name);

    if (name.isNotEmpty) {
      canSave = true;
    }
    return updateSubstates(
      appState,
      [
        updateLogsState(
            (logsState) => logsState.copyWith(selectedLog: Maybe<Log>.some(log), userUpdated: true, canSave: canSave)),
      ],
    );
  }
}

class LogSetCategories implements AppAction {
  final Log? log;
  final bool userUpdated;

  LogSetCategories({required this.log, this.userUpdated = false});

  @override
  AppState updateState(AppState appState) {
    Log newLog = appState.logsState.selectedLog.value;

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(
              selectedLog: Maybe.some(
                newLog.copyWith(
                  categories: List.from(log!.categories),
                  subcategories: List.from(log!.subcategories),
                ),
              ),
              userUpdated: userUpdated,
            )),
      ],
    );
  }
}

class LogSelectLog implements AppAction {
  final String? logId;

  LogSelectLog({this.logId});

  @override
  AppState updateState(AppState appState) {
    List<bool> expandedCategories = [];
    appState.logsState.logs[logId!]!.categories.forEach((element) {
      expandedCategories.add(false);
    });

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(
            selectedLog: Maybe<Log?>.some(appState.logsState.logs[logId!]),
            expandedCategories: expandedCategories,
            canSave: true)),
      ],
    );
  }
}

class LogClearSelected implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(selectedLog: Maybe<Log>.none(), canSave: false)),
      ],
    );
  }
}

class SetLogs implements AppAction {
  final Iterable<Log>? logList;

  SetLogs({this.logList});

  @override
  AppState updateState(AppState appState) {
    return _updateLogs(appState, (logs) {
      logs.addEntries(
        logList!.map(
          (log) => MapEntry(log.id, log),
        ),
      );
    });
  }
}

class LogReorder implements AppAction {
  final int? oldIndex;
  final int? newIndex;
  final List<Log>? logs;

  LogReorder({this.oldIndex, this.newIndex, this.logs});

  @override
  AppState updateState(AppState appState) {
    Map<String, Log> logsMap = Map.from(appState.logsState.logs);
    List<Log> organizedLogs = logs!;

    Log movedLog = organizedLogs.removeAt(oldIndex!);
    organizedLogs.insert(newIndex!, movedLog);

    organizedLogs.forEach((log) {
      logsMap[log.id] = log.copyWith(order: organizedLogs.indexOf(log));
    });

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(logs: logsMap)),
      ],
    );
  }
}

class LogAddUpdate implements AppAction {
  AppState updateState(AppState appState) {
    Log addedUpdatedLog = appState.logsState.selectedLog.value;
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    // Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);

    //check is the log currently exists
    if (addedUpdatedLog.id.length > 0 && appState.logsState.logs.containsKey(addedUpdatedLog.id)) {
      //update an existing log
      Env.logsFetcher.updateLog(addedUpdatedLog);

      //if there are new log members, add them to all transaction
      if (logs[addedUpdatedLog.id]!.logMembers.length != addedUpdatedLog.logMembers.length) {
        List<AppEntry> entries =
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

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(selectedLog: Maybe<Log>.none(), logs: logs, userUpdated: false)),
      ],
    );
  }
}

class LogAddMemberToSelectedLog implements AppAction {
  final String uid;
  final String name;

  LogAddMemberToSelectedLog({required this.uid, required this.name});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    Map<String, LogMember> logMembers = Map.from(log.logMembers);
    //orders added log member as next in the order
    logMembers.putIfAbsent(uid, () => LogMember(uid: uid, name: name, order: logMembers.length));

    log = log.copyWith(logMembers: logMembers);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(selectedLog: Maybe<Log>.some(log), userUpdated: true)),
      ],
    );
  }
}

//used for name changes
class LogUpdateLogMember implements AppAction {
  @override
  AppState updateState(AppState appState) {
    AppUser user = appState.authState.user.value;
    String uid = user.id;
    String? displayName = user.displayName;
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    appState.logsState.logs.forEach((key, log) {
      Map<String, LogMember> logMembers = Map.from(log.logMembers);
      logMembers.update(uid, (logMember) => logMember.copyWith(name: displayName));
      logs.update(key, (value) => value.copyWith(logMembers: logMembers)); //updates the log locally
      Env.logsFetcher.updateLog(logs[key]); //update log in the database
    });

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(logs: logs)),
      ],
    );
  }
}

class LogAddEditCategory implements AppAction {
  final AppCategory category;

  LogAddEditCategory({required this.category});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<AppCategory> categories = List.from(log.categories);
    List<AppCategory> subcategories = List.from(log.subcategories);
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    AppCategory updatedCategory = category;

    if (updatedCategory.id.length > 0 ) {
      //category does not exists, create category
      updatedCategory = updatedCategory.copyWith(id: Uuid().v4());
      categories.add(updatedCategory);
      expandedCategories.add(false);

      //every new category automatically gets a new subcategory "other"
      AppCategory otherSubcategory =
      AppCategory(parentCategoryId: updatedCategory.id, id: 'other${Uuid().v4()}', name: 'Other', emojiChar: '🤷');

      subcategories.add(otherSubcategory);
    } else {
      //category exists, update category
      categories[categories.indexWhere((e) => e.id == updatedCategory.id)] = updatedCategory;

    }

    log = log.copyWith(categories: categories, subcategories: subcategories);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(
            selectedLog: Maybe<Log>.some(log), expandedCategories: expandedCategories, userUpdated: true)),
      ],
    );
  }
}

class LogDeleteCategory implements AppAction {
  final AppCategory category;

  LogDeleteCategory({required this.category});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<AppCategory> categories = List.from(log.categories);
    List<AppCategory> subcategories = List.from(log.subcategories);
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    bool _canDeleteCategory = canDeleteCategory(id: category.id);

    //remove category and its subcategories if the category is not "no category"
    if (_canDeleteCategory) {
      int indexOfCategory = categories.indexWhere((element) => element.id == category.id);
      categories.removeAt(indexOfCategory);
      subcategories.removeWhere((e) => e.parentCategoryId == category.id);
      expandedCategories.removeAt(indexOfCategory);
    }

    log = log.copyWith(subcategories: subcategories, categories: categories);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(
            selectedLog: Maybe<Log>.some(log), expandedCategories: expandedCategories, userUpdated: true)),
      ],
    );
  }
}

class LogAddEditSubcategory implements AppAction {
  final AppCategory subcategory;

  LogAddEditSubcategory({required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<AppCategory> subcategories = List.from(log.subcategories);

    if (subcategory.id.length > 0) {
      //category does not exists, create category
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    } else {
      //category exists, update category
      subcategories[subcategories.indexWhere((e) => e.id == subcategory.id)] = subcategory;

    }

    log = log.copyWith(subcategories: subcategories);
    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(selectedLog: Maybe<Log>.some(log), userUpdated: true)),
      ],
    );
  }
}

class LogDeleteSubcategory implements AppAction {
  final AppCategory subcategory;

  LogDeleteSubcategory({required this.subcategory});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<AppCategory> subcategories = List.from(log.subcategories);
    bool _canDeleteSubcategory = canDeleteSubcategory(subcategory: subcategory);

    if (_canDeleteSubcategory) {
      subcategories.removeWhere((e) => e.id == subcategory.id);
      log = log.copyWith(subcategories: subcategories);
    }

    log = log.copyWith(subcategories: subcategories);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(selectedLog: Maybe<Log>.some(log), userUpdated: true)),
      ],
    );
  }
}

class LogExpandCollapseCategory implements AppAction {
  final int index;

  LogExpandCollapseCategory({required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(expandedCategories: expandedCategories)),
      ],
    );
  }
}

class LogReorderCategory implements AppAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;

  LogReorderCategory({required this.oldCategoryIndex, required this.newCategoryIndex});

  AppState updateState(AppState appState) {
    //reorder categories
    List<AppCategory> categories = List.from(appState.logsState.selectedLog.value.categories);
    categories = reorderLogSettingsCategories(
        categories: categories, oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex);

    //reorder expanded list
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    expandedCategories = reorderLogSettingsExpandedCategories(
        expandedCategories: expandedCategories, oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(
            selectedLog: Maybe<Log>.some(appState.logsState.selectedLog.value.copyWith(categories: categories)),
            expandedCategories: expandedCategories,
            userUpdated: true)),
      ],
    );
  }
}

class LogReorderSubcategory implements AppAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;
  final int oldSubcategoryIndex;
  final int newSubcategoryIndex;

  LogReorderSubcategory(
      {required this.oldCategoryIndex,
      required this.newCategoryIndex,
      required this.oldSubcategoryIndex,
      required this.newSubcategoryIndex});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    String oldParentId = log.categories[oldCategoryIndex].id;
    String newParentId = log.categories[newCategoryIndex].id;
    List<AppCategory> subcategories = List.from(log.subcategories);
    List<AppCategory> subsetOfSubcategories = List.from(subcategories);
    subsetOfSubcategories
        .retainWhere((subcategory) => subcategory.parentCategoryId == oldParentId); //get initial subset
    AppCategory subcategory = subsetOfSubcategories[oldSubcategoryIndex];

    subcategories = reorderSubcategoriesLogSetting(
        newSubcategoryIndex: newSubcategoryIndex,
        subcategory: subcategory,
        newParentId: newParentId,
        oldParentId: oldParentId,
        subsetOfSubcategories: subsetOfSubcategories,
        subcategories: subcategories);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(
            selectedLog: Maybe<Log>.some(appState.logsState.selectedLog.value.copyWith(subcategories: subcategories)),
            userUpdated: true)),
      ],
    );
  }
}

class LogUpdateCategoriesSubcategoriesOnEntryScreenClose implements AppAction {
  @override
  AppState updateState(AppState appState) {
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    logs = updateLogCategoriesSubcategoriesFromEntry(
        appState: appState, logId: appState.singleEntryState.selectedEntry.value.logId, logs: logs);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(logs: logs)),
        updateSingleEntryState((singleEntryState) => SingleEntryState.initial())
      ],
    );
  }
}

class DeleteLog implements AppAction {
  final Log? log;

  DeleteLog({this.log});

  @override
  AppState updateState(AppState appState) {
    LogsState updatedLogsState = appState.logsState;
    Settings settings = appState.settingsState.settings.value;
    updatedLogsState.logs.removeWhere((key, value) => key == log!.id);

    List<AppEntry> deletedEntriesList = [];
    List<Tag> deletedTagsList = [];
    Map<String, AppEntry> entriesMap = Map.from(appState.entriesState.entries);
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);

    entriesMap.forEach((key, entry) {
      if (entry.logId == log!.id) {
        deletedEntriesList.add(entry);
      }
    });

    entriesMap.removeWhere((key, entry) => entry.logId == log!.id);

    tagsMap.forEach((key, tag) {
      if (tag.logId == log!.id) {
        deletedTagsList.add(tag);
      }
    });

    tagsMap.removeWhere((key, tag) => tag.logId == log!.id);

    //ensures the default log is updated if the current log is default and deleted
    if (appState.settingsState.settings.value.defaultLogId == log!.id) {
      if (updatedLogsState.logs.isNotEmpty) {
        settings = settings.copyWith(
            defaultLogId: updatedLogsState.logs.values.firstWhere((element) => element.id != log!.id).id);
      } else {
        settings = settings.copyWith(defaultLogId: '');
      }
    }

    Env.entriesFetcher.batchDeleteEntries(deletedEntries: deletedEntriesList);
    Env.tagFetcher.batchDeleteTags(deletedTags: deletedTagsList);
    Env.logsFetcher.deleteLog(log: log);
    Env.settingsFetcher.writeAppSettings(settings);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => updatedLogsState.copyWith(selectedLog: Maybe<Log>.none(), userUpdated: false)),
        updateEntriesState((entriesState) => entriesState.copyWith(entries: entriesMap)),
        updateTagState((tagState) => tagState.copyWith(tags: tagsMap)),
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
      ],
    );
  }
}
