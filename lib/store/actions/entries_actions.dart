import 'dart:collection';

import 'package:meta/meta.dart';

import '../../entry/entry_model/single_entry_state.dart';
import '../../app/models/app_state.dart';
import '../../entries/entries_model/entries_state.dart';
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

    logTotals =
        entriesUpdateLogsTotals(logs: Map.from(appState.logsState.logs), logTotals: logTotals, entries: entries);

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

class EntriesDeleteSelectedEntry implements AppAction {
  @override
  AppState updateState(AppState appState) {
    Env.store.dispatch(EntryProcessing());
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    //List<AppCategory> categories = appState.singleEntryState.categories;
    Map<String, Tag> tags = appState.singleEntryState.tags;
    EntriesState updatedEntriesState = appState.entriesState;
    updatedEntriesState.entries.removeWhere((key, value) => key == entry.id);
    Map<String, LogTotal> logTotals = LinkedHashMap();

    entry.tagIDs.forEach((tagId) {
      //updates log list of tags
      Tag tag = tags[tagId]!;

      //decrement use of tag for this category and log
      tag = decrementCategorySubcategoryLogFrequency(updatedTag: tag, categoryId: entry.categoryId, subcategoryId: entry.subcategoryId);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });

    Env.entriesFetcher.deleteEntry(entry);

    //TODO update tags that have been decremented in the firestore

    logTotals = entriesUpdateLogsTotals(
        logs: Map.from(appState.logsState.logs), logTotals: logTotals, entries: updatedEntriesState.entries);

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => updatedEntriesState),
        updateSingleEntryState((singleEntryState) => SingleEntryState.initial()),
        updateLogTotalsState((logTotalsState) => logTotalsState.copyWith(logTotals: logTotals)),
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

    Maybe<Filter> updatedFilter = Maybe<Filter>.some(Filter.initial());

    if (logId == null) {
      //if filter has been changed, save new filter, if reset, pass no filter
      updatedFilter = filterState.updated ? filterState.filter : Maybe<Filter>.none();
    } else {
      //filter was set fro a logListTile and should only filter based on the log
      List<String?> selectedLogs = [];
      selectedLogs.add(logId);
      updatedFilter = Maybe<Filter>.some(updatedFilter.value.copyWith(selectedLogs: selectedLogs));
    }

    return updateSubstates(
      appState,
      [
        updateEntriesState((entriesState) => entriesState.copyWith(entriesFilter: updatedFilter)),
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
        updateEntriesState((entriesState) => entriesState.copyWith(entriesFilter: Maybe<Filter>.none())),
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

Map<String, LogTotal> entriesUpdateLogsTotals(
    {required Map<String, Log> logs,
    required Map<String, LogTotal> logTotals,
    required Map<String, AppEntry> entries}) {
  logs.forEach((key, log) {
    logTotals.putIfAbsent(key, () => updateLogMemberTotals(entries: entries.values.toList(), log: log));
  });
  return logTotals;
}
