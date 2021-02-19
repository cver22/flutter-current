
import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/log/log_totals_model/log_total.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses/tags/tag_model/tag_state.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';

abstract class AppAction {
  AppState updateState(AppState appState);
}

AppState _updateLogEntriesTagSettingState(
    AppState appState,
    LogsState updateLogState(LogsState logsState),
    EntriesState updateEntriesState(EntriesState entriesState),
    TagState updateTagState(TagState tagState),
    SettingsState updateSettingsState(SettingsState settingsState)) {
  return appState.copyWith(
      logsState: updateLogState(appState.logsState),
      entriesState: updateEntriesState(appState.entriesState),
      tagState: updateTagState(appState.tagState),
      settingsState: updateSettingsState(appState.settingsState));
}

AppState _updateLogsTagsSingleEntryState(
  AppState appState,
  LogsState updateLogState(LogsState logsState),
  TagState updateTagState(TagState tagState),
  SingleEntryState update(SingleEntryState singleEntryState),
) {
  return appState.copyWith(
    logsState: updateLogState(appState.logsState),
    tagState: updateTagState(appState.tagState),
    singleEntryState: update(appState.singleEntryState),
  );
}

AppState _updateTagSingleEntryState(
  AppState appState,
  TagState updateTagState(TagState tagState),
  SingleEntryState update(SingleEntryState singleEntryState),
) {
  return appState.copyWith(
    tagState: updateTagState(appState.tagState),
    singleEntryState: update(appState.singleEntryState),
  );
}

class DeleteLog implements AppAction {
  //This action updates multiple states simultaneously
  final Log log;

  DeleteLog({this.log});

  @override
  AppState updateState(AppState appState) {
    LogsState updatedLogsState = appState.logsState;
    Settings settings = appState.settingsState.settings.value;
    updatedLogsState.logs.removeWhere((key, value) => key == log.id);

    List<MyEntry> deletedEntriesList = [];
    List<Tag> deletedTagsList = [];
    Map<String, MyEntry> entriesMap = Map.from(appState.entriesState.entries);
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);

    entriesMap.forEach((key, entry) {
      if (entry.logId == log.id) {
        deletedEntriesList.add(entry);
      }
    });

    entriesMap.removeWhere((key, entry) => entry.logId == log.id);

    tagsMap.forEach((key, tag) {
      if (tag.logId == log.id) {
        deletedTagsList.add(tag);
      }
    });

    tagsMap.removeWhere((key, tag) => tag.logId == log.id);

    //TODO likely need a method to reset the default to nothing, else statement for the above
    //ensures the default log is updated if the current log is default and deleted
    if (appState.settingsState.settings.value.defaultLogId == log.id && updatedLogsState.logs.isNotEmpty) {
      settings = settings.copyWith(
          defaultLogId: updatedLogsState.logs.values.firstWhere((element) => element.id != log.id).id);
    }

    Env.entriesFetcher.batchDeleteEntries(deletedEntries: deletedEntriesList);
    Env.tagFetcher.batchDeleteTags(deletedTags: deletedTagsList);
    Env.logsFetcher.deleteLog(log: log);

    return _updateLogEntriesTagSettingState(
      appState,
      (logsState) => updatedLogsState.copyWith(selectedLog: Maybe.none(), userUpdated: false),
      (entriesState) => entriesState.copyWith(entries: entriesMap),
      (tagState) => tagState.copyWith(tags: tagsMap),
      (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)),
    );
  }
}

class DeleteTagFromEntryScreen implements AppAction {
  final Tag tag;

  DeleteTagFromEntryScreen({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);
    Map<String, Tag> entryTagsMap = Map.from(appState.singleEntryState.tags);
    tagsMap.removeWhere((key, value) => key == tag.id);
    entryTagsMap.removeWhere((key, value) => key == tag.id);

    Env.tagFetcher.deleteTag(tag);

    return _updateTagSingleEntryState(
      appState,
      (tagState) => tagState.copyWith(tags: tagsMap),
      (singleEntryState) => singleEntryState.copyWith(tags: entryTagsMap, userUpdated: true),
    );
  }
}

class AddUpdateSingleEntryAndTags implements AppAction {
  //submits new entry to the entries list and the clear the singleEntryState
  final MyEntry entry;

  AddUpdateSingleEntryAndTags({this.entry});

  AppState updateState(AppState appState) {
    List<Tag> tagsToAddToDatabase = [];
    List<Tag> tagsToUpdateInDatabase = [];
    Map<String, Tag> addedUpdatedTags = Map.from(appState.singleEntryState.tags);
    Map<String, Tag> masterTagList = Map.from(appState.tagState.tags);
    Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    MyEntry updatedEntry = entry;

    Env.store.dispatch(SingleEntryProcessing());

    //update entry for state and database
    if (updatedEntry.id != null &&
        updatedEntry !=
            appState.entriesState.entries.entries
                .map((e) => e.value)
                .toList()
                .firstWhere((element) => element.id == entry.id)) {
      //update entry if id is not null and thus already exists an the entry has been modified
      Env.entriesFetcher.updateEntry(entry);
    } else if (updatedEntry.id == null) {
      //if no category has been chosen, automatically set NO_CATEGORY
      String categoryId = updatedEntry?.categoryId ?? NO_CATEGORY;
      String subcategoryId = updatedEntry?.subcategoryId;

      if (categoryId != NO_CATEGORY && categoryId != TRANSFER_FUNDS && subcategoryId == null) {
        //if the category has been chosen but not the subcategory, automatically set subcategory to "other"

        List<AppCategory> subcategories = logs[updatedEntry.logId].subcategories;

        subcategoryId = subcategories
            .firstWhere((element) => element.parentCategoryId == categoryId && element.id.contains(OTHER))
            .id;
      }

      //save new entry using the user id to help minimize chance of duplication of entry ids in the database
      Env.entriesFetcher.addEntry(updatedEntry.copyWith(
          id: '${appState.authState.user.value.id}-${Uuid().v4()}',
          categoryId: categoryId,
          subcategoryId: subcategoryId));
    }

    //update entries for total only
    entries.update(updatedEntry.id, (value) => updatedEntry, ifAbsent: () => updatedEntry);

    //update tags state
    addedUpdatedTags.forEach((key, tag) {
      if (!masterTagList.containsKey(key)) {
        //tag doesn't exist and will be added

        masterTagList.putIfAbsent(key, () => tag);
        tagsToAddToDatabase.add(tag);
      } else if (masterTagList.containsKey(key) && masterTagList[key] != tag) {
        // if the tag exists and has changed, update it
        masterTagList.update(key, (value) => tag); // update the local tag map
        tagsToUpdateInDatabase.add(tag); //updates list of tags that will be sent to database
      }
    });

    //update tags database
    Env.tagFetcher.batchAddUpdate(addedTags: tagsToAddToDatabase, updatedTags: tagsToUpdateInDatabase);

    //update logs total in state
    //logs.updateAll((key, log) => _updateLogMemberTotals(entries: entries.values.toList(), log: log));

    //update log categories and subcategories if they have changed
    logs = updateLogCategoriesSubcategoriesFromEntry(appState: appState, logId: updatedEntry.logId, logs: logs);

    return _updateLogsTagsSingleEntryState(
      appState,
      (logsState) => logsState.copyWith(logs: logs),
      (tagState) => tagState.copyWith(tags: masterTagList),
      (singleEntryState) => SingleEntryState.initial(),
    );
  }
}

Map<String, Log> updateLogCategoriesSubcategoriesFromEntry(
    {@required AppState appState, @required String logId, @required Map<String, Log> logs}) {
  Log log = logs[logId];
  if (appState.singleEntryState.categories != log.categories ||
      appState.singleEntryState.subcategories != log.subcategories) {
    log = log.copyWith(
        categories: appState.singleEntryState.categories, subcategories: appState.singleEntryState.subcategories);
    logs.update(log.id, (value) => log);
    //send updated log to database
    Env.logsFetcher.updateLog(log);
  }
  return logs;
}

LogTotal updateLogMemberTotals({@required List<MyEntry> entries, @required Log log}) {
  Map<String, LogMember> logMembers = Map.from(log.logMembers);
  DateTime now = DateTime.now();

  int currentMonth = now.month;
  int currentYear = now.year;

  int lastMonth = currentMonth - 1 == 0 ? 12 : currentMonth - 1;
  int lastMonthYear = lastMonth == 12 ? currentYear - 1 : currentYear;

  int thisMonthTotalPaid = 0;
  int lastMonthTotalPaid = 0;
  int sameMonthLastYearTotalPaid = 0;
  int daysSoFar = now.day > 0 ? now.day : 1;

  entries.removeWhere((entry) => entry.logId != log.id);

  logMembers.updateAll((key, value) => value.copyWith(paid: 0, spent: 0));

  entries.forEach((entry) {
    DateTime entryDate = entry?.dateTime;
    int entryMonth = entryDate.month;
    int entryYear = entryDate.year;

    if (entryYear == currentYear && entryMonth == currentMonth) {
      entry.entryMembers.forEach((key, member) {
        int paid = member?.paid ?? 0;
        int spent = member?.spent ?? 0;
        thisMonthTotalPaid += paid;

        logMembers.update(key, (value) => value.copyWith(paid: value.paid + paid, spent: value.spent + spent));
      });
    } else if (entryYear == lastMonthYear && entryMonth == lastMonth) {
      entry.entryMembers.forEach((key, member) {
        if (member.paid != null) {
          lastMonthTotalPaid += member.paid;
        }
      });
    } else if (entryYear == currentYear - 1 && entryMonth == currentMonth) {
      entry.entryMembers.forEach((key, member) {
        if (member.paid != null) {
          sameMonthLastYearTotalPaid += member.paid;
        }
      });
    }
  });

  return LogTotal(
      logMembers: logMembers,
      thisMonthTotalPaid: thisMonthTotalPaid,
      lastMonthTotalPaid: lastMonthTotalPaid,
      sameMonthLastYearTotalPaid: sameMonthLastYearTotalPaid,
      averagePerDay: (thisMonthTotalPaid / daysSoFar).round());
}

bool canDeleteCategory({@required String id}) {
  if (id == NO_CATEGORY || id == TRANSFER_FUNDS) {
    return false;
  }
  return true;
}

bool canDeleteSubcategory({@required AppCategory subcategory}) {
  if (subcategory.id.contains(OTHER)) {
    return false;
  }
  return true;
}

//used by setting and log to reorder subcategories
List<AppCategory> reorderSubcategoriesLogSetting(
    {@required AppCategory subcategory,
    @required String newParentId,
    @required String oldParentId,
    @required List<AppCategory> subsetOfSubcategories,
    @required List<AppCategory> subcategories,
    @required int newSubcategoryIndex}) {
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
  return subcategories;
}

//determine if the subcategory is special and connot be reOrdered
bool _canReorderSubcategory({@required AppCategory subcategory, @required String newParentId}) {
  if (newParentId == NO_CATEGORY || subcategory.id.contains(OTHER) || newParentId == TRANSFER_FUNDS) {
    return false;
  }
  return true;
}
