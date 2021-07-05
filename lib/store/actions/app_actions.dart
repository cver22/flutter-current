import '../../filter/filter_model/filter.dart';
import '../../utils/maybe.dart';
import '../../filter/filter_model/filter_state.dart';
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
import '../../currency/currency_models/currency_state.dart';

abstract class AppAction {
  AppState updateState(AppState appState);
}

AppState updateSubstates(AppState state, List<AppState Function(AppState)> updates) {
  return updates.fold(state, (updatedState, update) => update(updatedState));
}

AppState Function(AppState) updateLogsState(LogsState update(logsState)) {
  return (state) => state.copyWith(logsState: update(state.logsState));
}

AppState Function(AppState) updateEntriesState(EntriesState update(entriesState)) {
  return (state) => state.copyWith(entriesState: update(state.entriesState));
}

AppState Function(AppState) updateSettingsState(SettingsState update(settingsState)) {
  return (state) => state.copyWith(settingsState: update(state.settingsState));
}

AppState Function(AppState) updateSingleEntryState(SingleEntryState update(singleEntryState)) {
  return (state) => state.copyWith(singleEntryState: update(state.singleEntryState));
}

AppState Function(AppState) updateTagState(TagState? update(tagState)) {
  return (state) => state.copyWith(tagState: update(state.tagState));
}

AppState Function(AppState) updateLogTotalsState(LogTotalsState update(logTotalsState)) {
  return (state) => state.copyWith(logTotalsState: update(state.logTotalsState));
}

AppState Function(AppState) updateFilterState(FilterState update(filterState)) {
  return (state) => state.copyWith(filterState: update(state.filterState));
}

AppState Function(AppState) updateCurrencyState(CurrencyState update(currencyState)) {
  return (state) => state.copyWith(currencyState: update(state.currencyState));
}

Map<String, Log> updateLogCategoriesSubcategoriesFromEntry(
    {required AppState appState, required String? logId, required Map<String, Log> logs}) {
  Log log = logs[logId!]!;
  if (appState.singleEntryState.categories != log.categories ||
      appState.singleEntryState.subcategories != log.subcategories) {
    log = log.copyWith(
        categories: appState.singleEntryState.categories, subcategories: appState.singleEntryState.subcategories);
    logs.update(log.id!, (value) => log);
    //send updated log to database
    Env.logsFetcher.updateLog(log);
  }
  return logs;
}

LogTotal updateLogMemberTotals({required List<AppEntry> entries, required Log log}) {
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

  entries.removeWhere((entry) => entry.logId != log.id || entry.categoryId == TRANSFER_FUNDS);

  logMembers.updateAll((key, value) => value.copyWith(paid: 0, spent: 0));

  entries.forEach((entry) {
    DateTime entryDate = entry.dateTime;
    int entryMonth = entryDate.month;
    int entryYear = entryDate.year;

    if (entryYear == currentYear && entryMonth == currentMonth) {
      entry.entryMembers.forEach((key, member) {
        int paid = 0;
        int spent = 0;
        if (member.paying && member.paid != null) {
          paid = member.paid!;
        }
        if (member.spending && member.spent != null) {
          spent = member.spent!;
        }

        thisMonthTotalPaid += paid;

        logMembers.update(
            key, (value) => value.copyWith(paid: (value.paid ?? 0) + paid, spent: (value.spent ?? 0) + spent));
      });
    } else if (entryYear == lastMonthYear && entryMonth == lastMonth) {
      entry.entryMembers.forEach((key, member) {
        if (member.paid != null) {
          lastMonthTotalPaid += member.paid!;
        }
      });
    } else if (entryYear == currentYear - 1 && entryMonth == currentMonth) {
      entry.entryMembers.forEach((key, member) {
        if (member.paid != null) {
          sameMonthLastYearTotalPaid += member.paid!;
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

bool canDeleteCategory({required String? id}) {
  if (id != null && id == NO_CATEGORY || id == TRANSFER_FUNDS) {
    return false;
  }
  return true;
}

bool canDeleteSubcategory({required AppCategory subcategory}) {
  if (subcategory.id != null && subcategory.id!.contains(OTHER)) {
    return false;
  }
  return true;
}

//used by setting and log to reorder subcategories
List<AppCategory> reorderSubcategoriesLogSetting(
    {required AppCategory subcategory,
    required String newParentId,
    required String oldParentId,
    required List<AppCategory> subsetOfSubcategories,
    required List<AppCategory> subcategories,
    required int newSubcategoryIndex}) {
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

//determine if the subcategory is special and cannot be reOrdered
bool _canReorderSubcategory({required AppCategory subcategory, required String newParentId}) {
  if (newParentId == NO_CATEGORY ||
      (subcategory.id != null && subcategory.id!.contains(OTHER)) ||
      newParentId == TRANSFER_FUNDS) {
    return false;
  }
  return true;
}

List<Tag> buildSearchedTagsList(
    {required List<Tag> tags, required List<String> tagIds, int maxTags = -1, required String? search}) {
  int tagCount = 0;
  List<Tag> searchedTags = [];

  if (search != null && search.length > 0) {
    for (int i = 0; i < tags.length; i++) {
      Tag tag = tags[i];

      //add tag to searched list if it is not already in the entry tag list
      if (tag.name.toLowerCase().contains(search.toLowerCase()) && !tagIds.contains(tag.id)) {
        searchedTags.add(tag);
        tagCount++;
      }

      //limit number of search results to 10 if maxTags passed
      if (maxTags > -1 && tagCount >= maxTags) {
        break;
      }
    }
  }
  return searchedTags;
}

List<AppCategory> reorderLogSettingsCategories(
    {required List<AppCategory> categories, required int oldCategoryIndex, required int newCategoryIndex}) {
  AppCategory movedCategory = categories.removeAt(oldCategoryIndex);
  categories.insert(newCategoryIndex, movedCategory);
  return categories;
}

List<bool> reorderLogSettingsExpandedCategories(
    {required List<bool> expandedCategories, required int oldCategoryIndex, required int newCategoryIndex}) {
  bool movedExpansion = expandedCategories.removeAt(oldCategoryIndex);
  expandedCategories.insert(newCategoryIndex, movedExpansion);
  return expandedCategories;
}

Map<String, AppEntry> buildFilteredEntries({
  required List<AppEntry> entries,
  required Filter filter,
  required Map<String, Log> logs,
  required Map<String, Tag> allTags,
}) {
  //only processes filters if a filter is present
    //minimum entry date
    if (filter.startDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isBefore(filter.startDate.value!));
    }
    //maximum entry date
    if (filter.endDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isAfter(filter.endDate.value!));
    }
    //is the entry logId found in the list of logIds selected
    if (filter.selectedLogs.isNotEmpty) {
      entries.removeWhere((entry) => !filter.selectedLogs.contains(entry.logId));
    }

    if (filter.selectedCurrencies.isNotEmpty) {
      entries.removeWhere((entry) => !filter.selectedCurrencies.contains(entry.currency));
    }

    if (filter.minAmount.isSome) {
      entries.removeWhere((entry) => entry.amount < filter.minAmount.value!);
    }
    //is the entry amount more than the max amount
    if (filter.maxAmount.isSome) {
      entries.removeWhere((entry) => entry.amount > filter.maxAmount.value!);
    }

    //is the entry subcategoryId found in the list of subcategories selected
    if (filter.selectedSubcategories.isNotEmpty) {
      entries.removeWhere((entry) {
        List<AppCategory?> subcategories = logs[entry.logId]!.subcategories;

        AppCategory? subcategory;

        if (entry.subcategoryId != null) {
          subcategory = subcategories.firstWhere((subcategory) => subcategory!.id == entry.subcategoryId);
        }

        if (subcategory != null && filter.selectedSubcategories.contains(subcategory.id)) {
          //filter contains subcategory, show entry
          return false;
        } else {
          //filter does not contain subcategory, remove entry
          return true;
        }
      });
    }

    //is the entry categoryID found in the list of categories selected
    if (filter.selectedCategories.length > 0) {
      entries.removeWhere((entry) {
        List<AppCategory?> categories = logs[entry.logId]!.categories;
        String categoryName = categories.firstWhere((category) => category!.id! == entry.categoryId)!.name!;

        if (filter.selectedCategories.contains(categoryName)) {
          //filter contains category, show entry
          return false;
        } else {
          //filter does not contain category, remove entry
          return true;
        }
      });
    }

    //filter entries by who spent
    if (filter.membersPaid.length > 0) {
      entries.retainWhere((entry) {
        List<String> uids = [];
        bool retain = false;
        entry.entryMembers.values.forEach((entryMember) {
          if (entryMember.paying) {
            uids.add(entryMember.uid);
          }
        });

        filter.membersPaid.forEach((element) {
          if (uids.contains(element)) {
            retain = true;
          }
        });

        return retain;
      });
    }

    //filter entries by who paid
    if (filter.membersSpent.length > 0) {
      entries.retainWhere((entry) {
        List<String> uids = [];
        bool retain = false;
        entry.entryMembers.values.forEach((entryMember) {
          if (entryMember.spending) {
            uids.add(entryMember.uid);
          }
        });

        filter.membersSpent.forEach((element) {
          if (uids.contains(element)) {
            retain = true;
          }
        });

        return retain;
      });
    }

    //is the entry categoryID found in the list of categories selected
    if (filter.selectedTags.isNotEmpty) {
      entries.retainWhere((entry) {
        List<String> entryTagIds = entry.tagIDs;
        List<String> entryTagNames = [];
        bool retain = false;

        if (entryTagIds.isNotEmpty) {
          //get name of all tags in the entry
          entryTagIds.forEach((id) {
            //error checking for improperly deleted tags
            if (allTags.keys.contains(id)) {
              entryTagNames.add(allTags[id]!.name);
            }
          });

          for (int i = 0; i < entryTagNames.length; i++) {
            if (filter.selectedTags.contains(entryTagNames[i])) {
              //entry contains at least one instance of a filtered tag
              retain = true;
              break;
            }
          }
        }

        return retain;
      });
    }

  return Map.fromIterable(entries, key: (entry) => entry.id, value: (entry) => entry);
}
