import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../entry/entry_model/app_entry.dart';
import '../../filter/filter_model/filter.dart';
import '../../utils/maybe.dart';

@immutable
class EntriesState extends Equatable {
  final Map<String, AppEntry> entries;
  final bool isLoading;
  final Maybe<Filter> entriesFilter;
  final Maybe<Filter> chartFilter;
  final bool descending;
  final List<String> selectedEntries;

  EntriesState({
    required this.entries,
    required this.isLoading,
    required this.entriesFilter,
    required this.chartFilter,
    required this.descending,
    required this.selectedEntries,
  });

  factory EntriesState.initial() {
    return EntriesState(
      entries: LinkedHashMap(),
      isLoading: true,
      entriesFilter: Maybe.none(),
      chartFilter: Maybe.none(),
      descending: true,
      selectedEntries: <String>[],
    );
  }

  @override
  List<Object> get props => [entries, isLoading, entriesFilter, chartFilter, descending, selectedEntries];

  @override
  bool get stringify => true;

  EntriesState copyWith(
      {Map<String, AppEntry>? entries,
      bool? isLoading,
      Maybe<Filter>? entriesFilter,
      Maybe<Filter>? chartFilter,
      bool? descending,
      List<String>? selectedEntries}) {
    if ((entries == null || identical(entries, this.entries)) &&
        (isLoading == null || identical(isLoading, this.isLoading)) &&
        (entriesFilter == null || identical(entriesFilter, this.entriesFilter)) &&
        (chartFilter == null || identical(chartFilter, this.chartFilter)) &&
        (descending == null || identical(descending, this.descending)) &&
        (selectedEntries == null || identical(selectedEntries, this.selectedEntries))) {
      return this;
    }

    return new EntriesState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      entriesFilter: entriesFilter ?? this.entriesFilter,
      chartFilter: chartFilter ?? this.chartFilter,
      descending: descending ?? this.descending,
      selectedEntries: selectedEntries ?? this.selectedEntries,
    );
  }
}
