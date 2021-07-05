import 'dart:collection';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';

import '../../entry/entry_model/single_entry_state.dart';
import '../../app/models/app_state.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../env.dart';
import '../../filter/filter_model/filter.dart';
import '../../filter/filter_model/filter_state.dart';
import '../../log/log_model/log.dart';
import '../../log/log_totals_model/log_total.dart';
import '../../tags/tag_model/tag.dart';
import '../../utils/maybe.dart';
import 'app_actions.dart';
import 'single_entry_actions.dart';

class EntriesSetLoading implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(isLoading: true)),
      ],
    );
  }
}

class EntriesSetLoaded implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(isLoading: false)),
      ],
    );
  }
}

class EntriesSetEntries implements AppAction {
  final Iterable<AppEntry>? entryList;

  EntriesSetEntries({this.entryList});

  @override
  AppState updateState(AppState appState) {
    Map<String, AppEntry> entries = Map.from(appState.entriesState.entries);
    Map<String, LogTotal> logTotals = LinkedHashMap();

    entries.addEntries(
      entryList!.map((entry) => MapEntry(entry.id, entry)),
    );

    logTotals = _entriesUpdateLogsTotals(
      logs: Map.from(appState.logsState.logs),
      logTotals: logTotals,
      entries: entries,
    );

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(entries: entries)),
        updateLogTotalsState((logTotalsState) => logTotalsState.copyWith(logTotals: logTotals)),
      ],
    );
  }
}

class EntriesSetOrder implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(descending: !appState.entriesState.descending)),
      ],
    );
  }
}

class EntriesSetEntriesFilter implements AppAction {
  final String? logId;

  EntriesSetEntriesFilter({this.logId});

  @override
  AppState updateState(AppState appState) {
    FilterState filterState = appState.filterState;
    Map<String, AppEntry> filteredEntries = <String, AppEntry>{};

    Maybe<Filter> updatedFilter = Maybe<Filter>.some(Filter.initial());

    if (logId == null) {
      //if filter has been changed, save new filter, if reset, pass no filter
      updatedFilter = filterState.updated ? filterState.filter : Maybe<Filter>.none();
    } else {
      //filter was set fro a logListTile and should only filter based on the log
      List<String> selectedLogs = [];
      selectedLogs.add(logId!);
      updatedFilter = Maybe<Filter>.some(updatedFilter.value.copyWith(selectedLogs: selectedLogs));
    }

    filteredEntries = buildFilteredEntries(
      entries: appState.entriesState.entries.values.toList(),
      filter: updatedFilter.value,
      logs: Map<String, Log>.of(appState.logsState.logs),
      allTags: Map<String, Tag>.of(appState.tagState.tags),
    );

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(
              entriesFilter: updatedFilter,
              filteredEntries: filteredEntries,
            )),
        updateFilterState((filterState) => FilterState.initial()),
      ],
    );
  }
}

class EntriesClearEntriesFilter implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(
              entriesFilter: Maybe<Filter>.none(),
              filteredEntries: <String, AppEntry>{},
            )),
      ],
    );
  }
}

class EntriesSetChartFilter implements AppAction {
  @override
  AppState updateState(AppState appState) {
    FilterState filterState = appState.filterState;

    //if filter has been changed, save new filter, if reset, pass no filter
    Maybe<Filter> updatedFilter = filterState.updated ? filterState.filter : Maybe<Filter>.none();

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(chartFilter: updatedFilter)),
        updateFilterState((filterState) => FilterState.initial()),
      ],
    );
  }
}

class EntriesClearChartFilter implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(chartFilter: Maybe<Filter>.none())),
      ],
    );
  }
}

class EntriesSelectEntry implements AppAction {
  final String entryId;

  EntriesSelectEntry({required this.entryId});

  @override
  AppState updateState(AppState appState) {
    List<String> selectedEntries = List<String>.from(appState.entriesState.selectedEntries);

    if (selectedEntries.contains(entryId)) {
      selectedEntries.remove(entryId);
    } else {
      selectedEntries.add(entryId);
    }

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(selectedEntries: selectedEntries)),
      ],
    );
  }
}

class EntriesClearSelection implements AppAction {
  @override
  AppState updateState(AppState appState) {
    List<String> selectedEntries = <String>[];

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(selectedEntries: selectedEntries)),
      ],
    );
  }
}

///ENTRIES DELETE ENTRIES///

class EntriesDeleteSelectedEntry implements AppAction {
  @override
  AppState updateState(AppState appState) {
    Env.store.dispatch(EntryProcessing());
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, Tag> tags = appState.singleEntryState.tags;
    Map<String, AppEntry> entriesMap = Map<String, AppEntry>.from(appState.entriesState.entries);
    Map<String, LogTotal> logTotals = LinkedHashMap();
    List<Tag> updatedTags = <Tag>[];
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    entriesMap.removeWhere((key, value) => key == entry.id);

    entry.tagIDs.forEach((tagId) {
      //updates log list of tags
      Tag tag = tags[tagId]!;

      //decrement use of tag for this category and log
      tag = decrementCategorySubcategoryLogFrequency(
          updatedTag: tag, categoryId: entry.categoryId, subcategoryId: entry.subcategoryId);

      //update state tags map
      tags.update(tag.id!, (value) => tag, ifAbsent: () => tag);
      //list of remote tags to update
      updatedTags.add(tag);
    });

    //update any changed categories/subcategories
    logs = updateLogCategoriesSubcategoriesFromEntry(appState: appState, logId: entry.logId, logs: logs);

    //also updates remote
    logTotals =
        _entriesUpdateLogsTotals(logs: Map.from(appState.logsState.logs), logTotals: logTotals, entries: entriesMap);

    Env.entriesFetcher.deleteEntry(entry);
    Env.tagFetcher.batchAddUpdate(addedTags: <Tag>[], updatedTags: updatedTags);

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(entries: entriesMap)),
        updateSingleEntryState((singleEntryState) => SingleEntryState.initial()),
        updateLogTotalsState((logTotalsState) => logTotalsState.copyWith(logTotals: logTotals)),
        updateTagState((tagState) => tagState.copyWith(tags: tags)),
        updateLogsState((logsState) => logsState.copyWith(logs: logs)),
      ],
    );
  }
}

class EntriesDeleteSelectedEntries implements AppAction {
  @override
  AppState updateState(AppState appState) {
    List<String> selectedEntries = List<String>.from(appState.entriesState.selectedEntries);
    List<AppEntry> deletedEntriesList = [];
    List<Tag> updatedTags = [];
    Map<String, AppEntry> entriesMap = Map.from(appState.entriesState.entries);
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);
    Map<String, LogTotal> logTotals = LinkedHashMap();

    selectedEntries.forEach((entryId) {
      AppEntry? entry = entriesMap.remove(entryId);
      if (entry != null) {
        entry.tagIDs.forEach((tagId) {
          //updates log list of tags
          Tag tag = tagsMap[tagId]!;

          //decrement use of tag for this category and log
          tag = decrementCategorySubcategoryLogFrequency(
              updatedTag: tag, categoryId: entry.categoryId, subcategoryId: entry.subcategoryId);

          //update state tags map
          tagsMap.update(tag.id!, (value) => tag, ifAbsent: () => tag);

          //list of remote tags to update, check if already added to the list
          if (updatedTags.contains(tag)) {
            //remove previously added tag, no need to update as we're pulling from the already updated tagsMap
            updatedTags.removeWhere((updatedTag) => updatedTag.id == tag.id);
            //add updated tag back to the list
            updatedTags.add(tag);
          } else {
            updatedTags.add(tag);
          }
        });

        deletedEntriesList.add(entry);
      }
    });

    Env.entriesFetcher.batchDeleteEntries(deletedEntries: selectedEntries);
    Env.tagFetcher.batchAddUpdate(addedTags: <Tag>[], updatedTags: updatedTags);

    logTotals =
        _entriesUpdateLogsTotals(logs: Map.from(appState.logsState.logs), logTotals: logTotals, entries: entriesMap);

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(entries: entriesMap, selectedEntries: <String>[])),
        updateTagState((tagState) => tagState.copyWith(tags: tagsMap)),
        updateLogTotalsState((logTotalsState) => logTotalsState.copyWith(logTotals: logTotals)),
      ],
    );
  }
}

Map<String, LogTotal> _entriesUpdateLogsTotals(
    {required Map<String, Log> logs,
    required Map<String, LogTotal> logTotals,
    required Map<String, AppEntry> entries}) {
  logs.forEach((key, log) {
    logTotals.putIfAbsent(key, () => updateLogMemberTotals(entries: entries.values.toList(), log: log));
  });
  return logTotals;
}

