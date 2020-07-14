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

class SetNewSelectedEntry implements Action {
  MyEntry entry = MyEntry();

  @override
  AppState updateState(AppState appState) {
    print('this is my new entry $entry');
    return _updateEntryState(
        appState,
        (entriesState) =>
            entriesState.copyWith(selectedEntry: Maybe.some(entry)));
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
  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String category;
  final String subcategory;
  final double amount;
  final String comment;
  final DateTime dateTime;

  UpdateSelectedEntry(
      {this.id,
      this.logId,
      this.currency,
      this.active,
      this.category,
      this.subcategory,
      this.amount,
      this.comment,
      this.dateTime});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
      appState,
      (entriesState) => entriesState.copyWith(
        selectedEntry: Maybe.some(
          entriesState.selectedEntry.value.copyWith(
            id: id,
            logId: logId,
            currency: currency,
            active: active,
            category: category,
            subcategory: subcategory,
            amount: amount,
            comment: comment,
            dateTime: dateTime,
          ),
        ),
      ),
    );
  }
}

class ChangeLog implements Action {
  final String logId;
  final String currency;

  ChangeLog({this.logId, this.currency});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
      appState,
      (entriesState) => entriesState.copyWith(
        selectedEntry: Maybe.some(
          entriesState.selectedEntry.value.changeLog(logId: logId, currency: currency),
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
