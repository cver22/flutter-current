import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../app/models/app_state.dart';
import '../../categories/categories_model/app_category/app_category.dart';
import '../../entries/entries_model/entries_state.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../entry/entry_model/single_entry_state.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../log/log_model/logs_state.dart';
import '../../log/log_totals_model/log_total.dart';
import '../../log/log_totals_model/log_totals_state.dart';
import '../../member/member_model/log_member_model/log_member.dart';
import '../../settings/settings_model/settings_state.dart';
import '../../tags/tag_model/tag.dart';
import '../../tags/tag_model/tag_state.dart';
import '../../utils/db_consts.dart';

abstract class AppAction {
  AppState updateState(AppState appState);
}

AppState updateSubstates(
    AppState state, List<AppState Function(AppState)> updates) {
  return updates.fold(state, (updatedState, update) => update(updatedState));
}

AppState Function(AppState) updateLogsState(LogsState update(logsState)) {
  return (state) => state.copyWith(logsState: update(state.logsState));
}

AppState Function(AppState) updateEntriesState(
    EntriesState update(entriesState)) {
  return (state) => state.copyWith(entriesState: update(state.entriesState));
}

AppState Function(AppState) updateSettingsState(
    SettingsState update(settingsState)) {
  return (state) => state.copyWith(settingsState: update(state.settingsState));
}

AppState Function(AppState) updateSingleEntryState(
    SingleEntryState update(singleEntryState)) {
  return (state) =>
      state.copyWith(singleEntryState: update(state.singleEntryState));
}

AppState Function(AppState) updateTagState(TagState update(tagState)) {
  return (state) => state.copyWith(tagState: update(state.tagState));
}

AppState Function(AppState) updateLogTotalsState(
    LogTotalsState update(logTotalsState)) {
  return (state) =>
      state.copyWith(logTotalsState: update(state.logTotalsState));
}

AppState Function(AppState) updateFilterState(
    FilterState update(filterState)) {
  return (state) =>
      state.copyWith(filterState: update(state.filterState));
}

Map<String, Log> updateLogCategoriesSubcategoriesFromEntry(
    {@required AppState appState,
    @required String logId,
    @required Map<String, Log> logs}) {
  Log log = logs[logId];
  if (appState.singleEntryState.categories != log.categories ||
      appState.singleEntryState.subcategories != log.subcategories) {
    log = log.copyWith(
        categories: appState.singleEntryState.categories,
        subcategories: appState.singleEntryState.subcategories);
    logs.update(log.id, (value) => log);
    //send updated log to database
    Env.logsFetcher.updateLog(log);
  }
  return logs;
}

LogTotal updateLogMemberTotals(
    {@required List<MyEntry> entries, @required Log log}) {
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

  entries.removeWhere(
      (entry) => entry.logId != log.id || entry.categoryId == TRANSFER_FUNDS);

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

        logMembers.update(
            key,
            (value) => value.copyWith(
                paid: value.paid + paid, spent: value.spent + spent));
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
  if (_canReorderSubcategory(
      subcategory: subcategory, newParentId: newParentId)) {
    if (oldParentId == newParentId) {
      //subcategory has not moved parents
      subsetOfSubcategories.remove(subcategory);
      subsetOfSubcategories.insert(newSubcategoryIndex, subcategory);
    } else {
      //category has moved parents, organize in new list with revised parent
      subsetOfSubcategories =
          List.from(subcategories); //reinitialize subset list
      subsetOfSubcategories.retainWhere(
          (subcategory) => subcategory.parentCategoryId == newParentId);
      subsetOfSubcategories.insert(newSubcategoryIndex,
          subcategory.copyWith(parentCategoryId: newParentId));
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

//determine if the subcategory is special and cannot be reOrdered
bool _canReorderSubcategory(
    {@required AppCategory subcategory, @required String newParentId}) {
  if (newParentId == NO_CATEGORY ||
      subcategory.id.contains(OTHER) ||
      newParentId == TRANSFER_FUNDS) {
    return false;
  }
  return true;
}

List<Tag> buildSearchedTagsList(
    {@required List<Tag> tags,
    @required List<String> tagIds,
    int maxTags = -1,
    @required String search}) {
  int tagCount = 0;
  List<Tag> searchedTags = [];

  if (search != null && search.length > 0) {
    for (int i = 0; i < tags.length; i++) {
      Tag tag = tags[i];

      //add tag to searched list if it is not already in the entry tag list
      if (tag.name.toLowerCase().contains(search.toLowerCase()) &&
          !tagIds.contains(tag.id)) {
        searchedTags.add(tag);
        tagCount++;
      }

      //limit number of search results to 10 if maxTags passed
      if (maxTags > -1 && tagCount >= maxTags) {
        break;
      }
    }
  }

  print('inside searched Tags: $searchedTags');

  return searchedTags;
}

List<AppCategory> reorderLogSettingsCategories(
    {@required List<AppCategory> categories,
    @required int oldCategoryIndex,
    @required int newCategoryIndex}) {
  AppCategory movedCategory = categories.removeAt(oldCategoryIndex);
  categories.insert(newCategoryIndex, movedCategory);
  return categories;
}

List<bool> reorderLogSettingsExpandedCategories(
    {@required List<bool> expandedCategories,
    @required int oldCategoryIndex,
    @required int newCategoryIndex}) {
  bool movedExpansion = expandedCategories.removeAt(oldCategoryIndex);
  expandedCategories.insert(newCategoryIndex, movedExpansion);
  return expandedCategories;
}
