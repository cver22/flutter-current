import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

@immutable
class EntriesState extends Equatable {
  final Map<String, MyEntry> entries;
  final bool isLoading;
  final Maybe<MyEntry> selectedEntry;

  EntriesState({this.entries, this.isLoading, this.selectedEntry});

  factory EntriesState.initial() {
    return EntriesState(
      entries: LinkedHashMap(),
      isLoading: true,
      selectedEntry: Maybe.none(),
    );
  }

  EntriesState copyWith({
    Map<String, MyEntry> entries,
    bool isLoading,
    Maybe<MyEntry> selectedEntry,
  }) {
    return EntriesState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      selectedEntry: selectedEntry ?? this.selectedEntry,
    );
  }

  @override
  List<Object> get props => [entries, isLoading, selectedEntry];

  @override
  bool get stringify => true;

}