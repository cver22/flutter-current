import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/my_entry.dart';

abstract class EntriesEvent extends Equatable {
  const EntriesEvent();

  @override
  List<Object> get props => [];
}


//tells bloc to load entries from repository
class LoadEntries extends EntriesEvent{}

//add new entry to list of entries
class EntryAdded extends EntriesEvent{
  final MyEntry entry;

  const EntryAdded({this.entry});

  @override
  List<Object> get props => [entry];

  @override
  String toString() => 'EntryAdded { entry: $entry }';

}

//update an existing entry
class EntryUpdated extends EntriesEvent{
  final MyEntry entry;

  const EntryUpdated({this.entry});

  @override
  List<Object> get props => [entry];

  @override
  String toString() => 'EntryUpdated { entry: $entry }';

}

//delete an existing log
class EntryDeleted extends EntriesEvent{
  final MyEntry entry;

  const EntryDeleted({this.entry});

  @override
  List<Object> get props => [entry];

  @override
  String toString() => 'EntryDeleted { entry: $entry }';

}

class EntriesUpdated extends EntriesEvent{
  final List<MyEntry> entries;

  const EntriesUpdated({this.entries});

  @override
  List<Object> get props => [entries];

  @override
  String toString() => 'EntriesUpdated { entries: $entries }';

}
