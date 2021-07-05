import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../entry/entry_model/app_entry.dart';
import '../../filter/filter_model/filter.dart';
import '../../utils/maybe.dart';

@immutable
class EntriesState extends Equatable {
  final Map<String, AppEntry> entries;
  final Map<String, AppEntry> filteredEntries;
  final bool isLoading;
  final Maybe<Filter> entriesFilter;
  final bool descending;
  final List<String> selectedEntries;

  EntriesState({
    required this.entries,
    required this.filteredEntries,
    required this.isLoading,
    required this.entriesFilter,
    required this.descending,
    required this.selectedEntries,
  });

  factory EntriesState.initial() {
    return EntriesState(
      entries: LinkedHashMap(),
      filteredEntries: LinkedHashMap(),
      isLoading: true,
      entriesFilter: Maybe.none(),
      descending: true,
      selectedEntries: <String>[],
    );
  }

  @override
  List<Object> get props => [entries, filteredEntries, isLoading, entriesFilter, descending, selectedEntries];

  @override
  bool get stringify => true;

  EntriesState copyWith({
    Map<String, AppEntry>? entries,
    Map<String, AppEntry>? filteredEntries,
    bool? isLoading,
    Maybe<Filter>? entriesFilter,
    bool? descending,
    List<String>? selectedEntries,
  }) {
    if ((entries == null || identical(entries, this.entries)) &&
        (filteredEntries == null || identical(filteredEntries, this.filteredEntries)) &&
        (isLoading == null || identical(isLoading, this.isLoading)) &&
        (entriesFilter == null || identical(entriesFilter, this.entriesFilter)) &&
        (descending == null || identical(descending, this.descending)) &&
        (selectedEntries == null || identical(selectedEntries, this.selectedEntries))) {
      return this;
    }

    return new EntriesState(
      entries: entries ?? this.entries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
      isLoading: isLoading ?? this.isLoading,
      entriesFilter: entriesFilter ?? this.entriesFilter,
      descending: descending ?? this.descending,
      selectedEntries: selectedEntries ?? this.selectedEntries,
    );
  }
}
