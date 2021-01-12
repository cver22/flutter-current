part of 'actions.dart';

AppState _updateEntriesLogsState(
  AppState appState,
  LogsState updateLogState(LogsState logsState),
  EntriesState update(EntriesState entriesState),
) {
  return appState.copyWith(
    logsState: updateLogState(appState.logsState),
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

class SetEntriesLoading implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(isLoading: true));
  }
}

class SetEntriesLoaded implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(isLoading: false));
  }
}

class SetEntries implements Action {
  final Iterable<MyEntry> entryList;

  SetEntries({this.entryList});

  //Only shows logs that have not been "deleted" using active filter
  @override
  AppState updateState(AppState appState) {
    Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    entries.addEntries(
      entryList.map((entry) => MapEntry(entry.id, entry)),
    );

    logs.updateAll((key, log) => _updateLogMemberTotals(entries: entries.values.toList(), log: log));

    return _updateEntriesLogsState(appState, (logsState) => logsState.copyWith(logs: logs), (entriesState) => entriesState.copyWith(entries: entries));
  }
}
