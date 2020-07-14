import 'dart:async';

import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/services/entries_repository.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

class EntriesFetcher {
  final AppStore _store;
  final EntriesRepository _entriesRepository;
  StreamSubscription _entriesSubscription;

  EntriesFetcher({
    @required AppStore store,
    @required EntriesRepository entriesRepository,
  })  : _store = store,
        _entriesRepository = entriesRepository;

  Future<void> loadEntries() async {
    _store.dispatch(SetEntriesLoading());
    _entriesSubscription?.cancel();
    _entriesSubscription = _entriesRepository
        .loadEntries(_store.state.authState.user.value)
        .listen(
          (entries) => _store.dispatch(SetEntries(entryList: entries)),
        );
    _store.dispatch(SetEntriesLoaded());
  }

  Future<void> addEntry(MyEntry entry) async {
    try {
      _entriesRepository.addNewEntry(
          entry.copyWith(id: Uuid().v4(), dateTime: DateTime.now()));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateEntry(MyEntry entry) async {
    _store.dispatch(ClearSelectedEntry());
    try {
      _entriesRepository.updateEntry(_store.state.authState.user.value, entry);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteEntry(MyEntry entry) async {
    _store.dispatch(ClearSelectedLog());
    try {
      _entriesRepository.deleteEntry(
          _store.state.authState.user.value, entry.copyWith(active: false));
    } catch (e) {
      print(e.toString());
    }
  }

  //TODO where to close the subscription when exiting the app?
  Future<void> close() async {
    _entriesSubscription?.cancel();
  }
}
