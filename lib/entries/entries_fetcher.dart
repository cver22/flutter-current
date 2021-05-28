import 'dart:async';

import '../entry/entry_model/app_entry.dart';
import '../env.dart';
import '../member/member_model/entry_member_model/entry_member.dart';
import '../member/member_model/log_member_model/log_member.dart';
import '../store/actions/entries_actions.dart';
import '../store/app_store.dart';
import 'entries_repository.dart';

class EntriesFetcher {
  final AppStore _store;
  final EntriesRepository _entriesRepository;
  StreamSubscription? _entriesSubscription;

  EntriesFetcher({
    required AppStore store,
    required EntriesRepository entriesRepository,
  })  : _store = store,
        _entriesRepository = entriesRepository;

  Future<void> loadEntries() async {
    _store.dispatch(EntriesSetLoading());
    _entriesSubscription?.cancel();
    _entriesSubscription = _entriesRepository
        .loadEntries(_store.state.authState.user.value)
        .listen(
          (entries) => _store.dispatch(EntriesSetEntries(entryList: entries)),
        );
    _store.dispatch(EntriesSetLoaded());

  }

  Future<void> addEntry(AppEntry entry) async {
    try {
      _entriesRepository.addNewEntry(entry);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateEntry(AppEntry entry) async {
    try {
      _entriesRepository.updateEntry(entry);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteEntry(AppEntry entry) async {
    try {
      _entriesRepository.deleteEntry(entry);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> batchUpdateEntries(
      {required List<AppEntry> entries,
      required Map<String?, LogMember> logMembers}) async {
    List<AppEntry> updatedEntries = [];

    //adds any new log members to all entries for the log
    entries.forEach((entry) {
      Map<String, EntryMember> entryMembers = Map.from(entry.entryMembers);
      logMembers.forEach((key, logMember) {
        if (!entry.entryMembers.containsKey(key)) {
          entryMembers.putIfAbsent(
              key!, () => EntryMember(uid: logMember.uid, spending: false, order: entry.entryMembers.length));
        }
      });
      updatedEntries.add(entry.copyWith(entryMembers: entryMembers));
    });

    if (updatedEntries.isNotEmpty) {
      try {
        _entriesRepository.batchUpdateEntries(updatedEntries: updatedEntries);

      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<void> batchDeleteEntries(
      {required List<AppEntry> deletedEntries}) async {
    //log has been deleted, delete all associated entries

    if (deletedEntries.isNotEmpty) {
      try {
        _entriesRepository.batchDeleteEntries(deletedEntries: deletedEntries);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  //TODO where to close the subscription when exiting the app?
  Future<void> close() async {
    _entriesSubscription?.cancel();
  }
}
