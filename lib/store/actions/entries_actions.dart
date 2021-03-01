import 'dart:collection';

import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_totals_model/log_total.dart';
import 'package:expenses/log/log_totals_model/log_totals_state.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/utils/maybe.dart';

import '../../env.dart';

AppState _updateEntriesLogTotalsState(
  AppState appState,
  LogTotalsState updateLogTotalsState(LogTotalsState logTotalsState),
  EntriesState update(EntriesState entriesState),
) {
  return appState.copyWith(
    logTotalsState: updateLogTotalsState(appState.logTotalsState),
    entriesState: update(appState.entriesState),
  );
}

AppState _updateEntriesState(
  AppState appState,
  EntriesState update(EntriesState entriesState),
) {
  return appState.copyWith(entriesState: update(appState.entriesState));
}

/*AppState _updateEntries(
  AppState appState,
  LogsState updateLogState(LogsState logsState),
  void updateInPlace(Map<String, MyEntry> entries),
) {
  Map<String, MyEntry> cloneMap = Map.from(appState.entriesState.entries);
  updateInPlace(cloneMap);
  return _updateEntriesLogsState(
    appState,
    (logsState) => updateLogState(appState.logsState),
    (entriesState) => entriesState.copyWith(entries: cloneMap),
  );
}*/

class EntriesSetLoading implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(isLoading: true));
  }
}

class EntriesSetLoaded implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(isLoading: false));
  }
}

class SetEntries implements AppAction {
  final Iterable<MyEntry> entryList;

  SetEntries({this.entryList});

  @override
  AppState updateState(AppState appState) {
    Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    Map<String, LogTotal> logTotals = LinkedHashMap();

    entries.addEntries(
      entryList.map((entry) => MapEntry(entry.id, entry)),
    );

    logs.forEach((key, log) {
      logTotals.putIfAbsent(key, () => updateLogMemberTotals(entries: entries.values.toList(), log: log));
    });

    return _updateEntriesLogTotalsState(appState, (logTotalsState) => logTotalsState.copyWith(logTotals: logTotals),
        (entriesState) => entriesState.copyWith(entries: entries));
  }
}

class EntriesSetOrder implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(
        appState, (entriesState) => entriesState.copyWith(descending: !appState.entriesState.descending));
  }
}

class EntriesDeleteSelectedEntry implements AppAction {
  @override
  AppState updateState(AppState appState) {
    Env.store.dispatch(SingleEntryProcessing());
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    List<AppCategory> categories = appState.singleEntryState.categories;
    Map<String, Tag> tags = appState.singleEntryState.tags;
    EntriesState updatedEntriesState = appState.entriesState;
    updatedEntriesState.entries.removeWhere((key, value) => key == entry.id);

    entry.tagIDs.forEach((tagId) {
      //updates log list of tags
      Tag tag = tags[tagId];

      //decrement use of tag for this category and log
      tag = decrementCategoryAndLogFrequency(updatedTag: tag, categoryId: entry?.categoryId);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });

    Env.entriesFetcher.deleteEntry(entry);

    //TODO send to update all changed tags
    //Map<String, Tag> stateTags = appState.tagState.tags;

    //TODO ask Boris, is this kind of action legal, or do I need to pass the revised state back to this action?
    Env.store.dispatch(ClearEntryState());

    return _updateEntriesState(appState, (entriesState) => updatedEntriesState);
  }
}

class EntriesSetEntriesFilter implements AppAction {

  @override
  AppState updateState(AppState appState) {
    FilterState filterState = appState.filterState;

    //if filter has been changed, save new filter, if reset, pass no filter
    Maybe<Filter> updatedFilter = filterState.updated ? filterState.filter : Maybe.none();

    return _updateEntriesState(
        appState, (entriesState) => entriesState.copyWith(entriesFilter: updatedFilter));
  }
}

class EntriesSetChartFilter implements AppAction {

  @override
  AppState updateState(AppState appState) {
    FilterState filterState = appState.filterState;

    //if filter has been changed, save new filter, if reset, pass no filter
    Maybe<Filter> updatedFilter = filterState.updated ? filterState.filter : Maybe.none();

    return _updateEntriesState(
        appState, (entriesState) => entriesState.copyWith(chartFilter: updatedFilter));
  }
}
