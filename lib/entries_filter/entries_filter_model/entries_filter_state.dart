import 'package:equatable/equatable.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/utils/maybe.dart';

class EntriesFilterState extends Equatable {
  final Maybe<EntriesFilter> entriesFilter;
  final List<bool> expandedCategories;

  EntriesFilterState( {this.entriesFilter, this.expandedCategories,});

  factory EntriesFilterState.initial() {
    return EntriesFilterState(
      entriesFilter: Maybe.none(),
      expandedCategories: List(),
    );
  }

  @override
  List<Object> get props => [entriesFilter, expandedCategories];

  @override
  bool get stringify => true;

  EntriesFilterState copyWith({
    Maybe<EntriesFilter> entriesFilter,
    List<bool> expandedCategories,
  }) {
    if ((entriesFilter == null || identical(entriesFilter, this.entriesFilter)) &&
        (expandedCategories == null || identical(expandedCategories, this.expandedCategories))) {
      return this;
    }

    return new EntriesFilterState(
      entriesFilter: entriesFilter ?? this.entriesFilter,
      expandedCategories: expandedCategories ?? this.expandedCategories,
    );
  }
}
