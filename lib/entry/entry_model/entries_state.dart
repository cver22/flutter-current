import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';

import 'package:meta/meta.dart';

@immutable
class EntriesState extends Equatable {
  final Map<String, MyEntry> entries;
  final bool isLoading;

  EntriesState({this.entries, this.isLoading});

  factory EntriesState.initial() {
    return EntriesState(
      entries: LinkedHashMap(),
      isLoading: true,
    );
  }

  EntriesState copyWith({
    Map<String, MyEntry> entries,
    bool isLoading,
  }) {
    return EntriesState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => [entries, isLoading];

  @override
  bool get stringify => true;
}
