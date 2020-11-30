part of 'actions.dart';

AppState _updateEntriesState(
  AppState appState,
  EntriesState update(EntriesState entriesState),
) {
  return appState.copyWith(entriesState: update(appState.entriesState));
}

AppState _updateEntries(
  AppState appState,
  void updateInPlace(Map<String, MyEntry> entries),
) {
  Map<String, MyEntry> cloneMap = Map.from(appState.entriesState.entries);
  updateInPlace(cloneMap);
  return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(entries: cloneMap));
}

class SetEntriesLoading implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(entriesState: appState.entriesState.copyWith(isLoading: true));
  }
}

class SetEntriesLoaded implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(entriesState: appState.entriesState.copyWith(isLoading: false));
  }
}

class SetEntries implements Action {
  final Iterable<MyEntry> entryList;

  SetEntries({this.entryList});

  //Only shows logs that have not been "deleted" using active filter
  @override
  AppState updateState(AppState appState) {
    return _updateEntries(appState, (entries) {
      entries.addEntries(
        entryList.map(
          (entry) => MapEntry(entry.id, entry),
        ),
      );
    });
  }
}
