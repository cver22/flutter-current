part of 'actions.dart';

AppState _updateEntryState(
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
  return _updateEntryState(
      appState, (entriesState) => entriesState.copyWith(entries: cloneMap));
}

class SetEntriesLoading implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(
        entriesState: appState.entriesState.copyWith(isLoading: true));
  }
}

class SetEntriesLoaded implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(
        entriesState: appState.entriesState.copyWith(isLoading: false));
  }
}

class SelectEntry implements Action {
  final String entryId;

  SelectEntry({this.entryId});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
        appState,
        (entriesState) => entriesState.copyWith(
            selectedEntry: Maybe.some(entriesState.entries[entryId])));
  }
}

class ClearSelectedEntry implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(appState,
        (entriesState) => entriesState.copyWith(selectedEntry: Maybe.none()));
  }
}

class UpdateSelectedEntry implements Action {
  final MyEntry entry;

  UpdateSelectedEntry({this.entry});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
      appState,
      (entriesState) => entriesState.copyWith(
        selectedEntry: Maybe.some(
          entriesState.selectedEntry.value.copy(entry),
        ),
      ),
    );
  }
}

class SetEntries implements Action {
  final Iterable<MyEntry> entryList;

  SetEntries({this.entryList});

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
