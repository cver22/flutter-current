import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/utils/maybe.dart';

import 'package:meta/meta.dart';

@immutable
class EntriesState extends Equatable {
  final Map<String, MyEntry> entries;
  final bool isLoading;
  final Maybe<EntriesFilter> entriesFilter;
  final Maybe<EntriesFilter> chartFilter;

  EntriesState( {this.entries, this.isLoading,this.entriesFilter, this.chartFilter});

  factory EntriesState.initial() {
    return EntriesState(
      entries: LinkedHashMap(),
      isLoading: true,
      entriesFilter: Maybe.none(),
      chartFilter: Maybe.none(),
    );
  }

  @override
  List<Object> get props => [entries, isLoading, entriesFilter];

  @override
  bool get stringify => true;

  EntriesState copyWith({
    Map<String, MyEntry> entries,
    bool isLoading,
    Maybe<EntriesFilter> entriesFilter,
    Maybe<EntriesFilter> chartFilter,
  }) {
    if ((entries == null || identical(entries, this.entries)) &&
        (isLoading == null || identical(isLoading, this.isLoading)) &&
        (entriesFilter == null || identical(entriesFilter, this.entriesFilter)) &&
        (chartFilter == null || identical(chartFilter, this.chartFilter))) {
      return this;
    }

    return new EntriesState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      entriesFilter: entriesFilter ?? this.entriesFilter,
      chartFilter: chartFilter ?? this.chartFilter,
    );
  }
}
