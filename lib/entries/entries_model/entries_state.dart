import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../entry/entry_model/app_entry.dart';
import '../../filter/filter_model/filter.dart';
import '../../utils/maybe.dart';

@immutable
class EntriesState extends Equatable {
  final Map<String, MyEntry> entries;
  final bool isLoading;
  final Maybe<Filter> entriesFilter;
  final Maybe<Filter> chartFilter;
  final bool descending;

  EntriesState(
      {this.entries,
      this.isLoading,
      this.entriesFilter,
      this.chartFilter,
      this.descending});

  factory EntriesState.initial() {
    return EntriesState(
      entries: LinkedHashMap(),
      isLoading: true,
      entriesFilter: Maybe.none(),
      chartFilter: Maybe.none(),
      descending: true,
    );
  }

  @override
  List<Object> get props =>
      [entries, isLoading, entriesFilter, chartFilter, descending];

  @override
  bool get stringify => true;

  EntriesState copyWith({
    Map<String, MyEntry> entries,
    bool isLoading,
    Maybe<Filter> entriesFilter,
    Maybe<Filter> chartFilter,
    bool descending,
  }) {
    if ((entries == null || identical(entries, this.entries)) &&
        (isLoading == null || identical(isLoading, this.isLoading)) &&
        (entriesFilter == null ||
            identical(entriesFilter, this.entriesFilter)) &&
        (chartFilter == null || identical(chartFilter, this.chartFilter)) &&
        (descending == null || identical(descending, this.descending))) {
      return this;
    }

    return new EntriesState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      entriesFilter: entriesFilter ?? this.entriesFilter,
      chartFilter: chartFilter ?? this.chartFilter,
      descending: descending ?? this.descending,
    );
  }
}
