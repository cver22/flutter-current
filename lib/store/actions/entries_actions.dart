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
  return _updateEntryState(appState, (entriesState) => entriesState.copyWith(entries: cloneMap));
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

class SetNewSelectedEntry implements Action {
  final String logId;

  SetNewSelectedEntry({@required this.logId});

  @override
  AppState updateState(AppState appState) {
    MyEntry _entry = MyEntry();
    Log _log = Env.store.state.logsState.logs[logId];
    _entry = _entry.copyWith(logId: _log.id, currency: _log.currency, dateTime: DateTime.now());
    print('this is my new entry $_entry');
    return _updateEntryState(appState, (entriesState) => entriesState.copyWith(selectedEntry: Maybe.some(_entry)));
  }
}

class SelectEntry implements Action {
  final String entryId;

  SelectEntry({@required this.entryId});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
        appState, (entriesState) => entriesState.copyWith(selectedEntry: Maybe.some(entriesState.entries[entryId])));
  }
}

class ClearSelectedEntry implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(appState, (entriesState) => entriesState.copyWith(selectedEntry: Maybe.none()));
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
  final List<String> tagIDs;

  UpdateSelectedEntry(
      {this.id,
      this.logId,
      this.currency,
      this.active,
      this.category,
      this.subcategory,
      this.amount,
      this.comment,
      this.dateTime,
      this.tagIDs});

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
            categoryId: category,
            subcategoryId: subcategory,
            amount: amount,
            comment: comment,
            dateTime: dateTime,
            tagIDs: tagIDs,
          ),
        ),
      ),
    );
  }
}

class ChangeEntryLog implements Action {
  final Log log;

  ChangeEntryLog({@required this.log});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
      appState,
      (entriesState) => entriesState.copyWith(
        selectedEntry: Maybe.some(
          entriesState.selectedEntry.value.changeLog(log: log),
        ),
      ),
    );
  }
}

class ChangeEntryCategories implements Action {
  final String category;

  ChangeEntryCategories({@required this.category});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
      appState,
      (entriesState) => entriesState.copyWith(
        selectedEntry: Maybe.some(
          entriesState.selectedEntry.value.changeCategories(category: category),
        ),
      ),
    );
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
