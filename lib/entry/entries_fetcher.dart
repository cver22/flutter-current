import 'dart:async';

import 'package:expenses/entry/entries_repository.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:meta/meta.dart';

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
    _entriesSubscription = _entriesRepository.loadEntries(_store.state.authState.user.value).listen(
          (entries) => _store.dispatch(SetEntries(entryList: entries)),
        );
    _store.dispatch(SetEntriesLoaded());
  }

  Future<void> addEntry(MyEntry entry) async {
    try {
      _entriesRepository.addNewEntry(entry);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateEntry(MyEntry entry) async {
    try {
      _entriesRepository.updateEntry(entry);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteEntry(MyEntry entry) async {
    try {
      _entriesRepository.deleteEntry(entry);
    } catch (e) {
      print(e.toString());
    }
  }

  //TODO where to close the subscription when exiting the app?
  Future<void> close() async {
    _entriesSubscription?.cancel();
  }
}
