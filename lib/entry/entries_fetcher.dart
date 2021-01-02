import 'dart:async';

import 'package:expenses/entry/entries_repository.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
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

  Future<void> batchUpdateEntries({@required List<MyEntry> entries, @required Map<String, LogMember> logMembers}) {
    List<MyEntry> updatedEntries = [];

    //adds any new log members to all entries for the log
    entries.forEach((entry) {
      Map<String, EntryMember> entryMembers = Map.from(entry.entryMembers);
      logMembers.forEach((key, logMember) {
        if(!entry.entryMembers.containsKey(key)) {
          entryMembers.putIfAbsent(key, () => EntryMember(uid: logMember.uid, spending: false));
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

  Future<void> batchDeleteEntries({@required List<MyEntry> deletedEntries}) async {
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
