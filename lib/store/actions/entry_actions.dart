part of 'actions.dart';

AppState _updateEntryState(AppState appState,
    EntryState update(EntryState entryState),) {
  return appState.copyWith(entryState: update(appState.entryState));
}

class UpdateEntryState implements Action {
  final Maybe<MyEntry> selectedEntry;
  final Maybe<Tag> selectedTag;
  final List<Tag> logTagList;
  final bool savingEntry;

  UpdateEntryState({this.selectedEntry, this.selectedTag, this.logTagList, this.savingEntry});

  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
              selectedEntry: selectedEntry,
              selectedTag: selectedTag,
              logTagList: logTagList,
              savingEntry: savingEntry,
            ));
  }
}

class SetNewSelectedEntry implements Action {
  final String logId;

  SetNewSelectedEntry({@required this.logId});

  @override
  AppState updateState(AppState appState) {
    MyEntry _entry = MyEntry();
    Log _log = Env.store.state.logsState.logs[logId];
    _entry = _entry.copyWith(logId: _log.id, currency: _log.currency, dateTime: DateTime.now(), tagIDs: []);
    print('this is my new entry $_entry');
    return _updateEntryState(
        appState, (entryState) => entryState.copyWith(selectedEntry: Maybe.some(_entry), logTagList: _log.tags));
  }
}

class SelectEntry implements Action {
  final String entryId;

  SelectEntry({@required this.entryId});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = Env.store.state.entriesState.entries[entryId];

    return _updateEntryState(appState,
            (entryState) =>
            entryState.copyWith(selectedEntry: Maybe.some(entry), logTagList: Env.store.state.logsState.logs.values
                .firstWhere((element) => element.id == entry.logId)
                .tags));
  }
}

class ClearSelectedEntry implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(appState, (entryState) => entryState.copyWith(selectedEntry: Maybe.none()));
  }
}

class ClearEntryState implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateEntryState(appState, (entryState) => EntryState.initial());
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

  UpdateSelectedEntry({this.id,
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
          (entryState) =>
          entryState.copyWith(
            selectedEntry: Maybe.some(
              entryState.selectedEntry.value.copyWith(
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
          (entryState) =>
          entryState.copyWith(
            selectedEntry: Maybe.some(
              entryState.selectedEntry.value.changeLog(log: log),
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
          (entryState) =>
          entryState.copyWith(
            selectedEntry: Maybe.some(
              entryState.selectedEntry.value.changeCategories(category: category),
            ),
          ),
    );
  }
}
