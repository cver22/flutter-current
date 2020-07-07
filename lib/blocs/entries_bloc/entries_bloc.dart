/*
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:expenses/services/entries_repository.dart';
import 'package:flutter/foundation.dart';
import './bloc.dart';

class EntriesBloc extends Bloc<EntriesEvent, EntriesState> {
  final FirebaseEntriesRepository _entriesRepository;
  StreamSubscription _entriesSubscription;

  EntriesBloc({@required EntriesRepository entriesRepository})
      : assert(entriesRepository != null),
        _entriesRepository = entriesRepository;

  @override
  EntriesState get initialState => EntriesLoading();

  @override
  Stream<EntriesState> mapEventToState(EntriesEvent event) async* {
    if (event is LoadEntries) {
      yield* _mapEntriesLoadedToState();
    } else if (event is EntryAdded) {
      yield* _mapEntryAddedToState(event);
    } else if (event is EntryUpdated) {
      yield* _mapEntryUpdatedToState(event);
    } else if (event is EntryDeleted) {
      yield* _mapEntryDeletedToState(event);
    } else if (event is EntriesUpdated) {
      yield* _mapEntriesUpdatedToState(event);
    }
  }

  Stream<EntriesState> _mapEntriesLoadedToState() async* {
    _entriesSubscription?.cancel();
    _entriesSubscription = _entriesRepository.loadEntries().listen(
          (entries) => add(EntriesUpdated(entries: entries)),
    );
  }

  Stream<EntriesState> _mapEntryAddedToState(EntryAdded event) {
    _entriesRepository.addNewEntry(event.entry);
  }

  Stream<EntriesState> _mapEntryUpdatedToState(EntryUpdated event) {
    _entriesRepository.updateEntry(event.entry);
  }

  Stream<EntriesState> _mapEntryDeletedToState(EntryDeleted event) async* {
    _entriesRepository.deleteEntry(event.entry);
  }

  Stream<EntriesState> _mapEntriesUpdatedToState(EntriesUpdated event) async* {
    yield EntriesLoaded(event.entries);
  }

  @override
  Future<void> close() {
    _entriesSubscription?.cancel();
    return super.close();
  }
}
*/
