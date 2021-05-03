import 'dart:collection';

import 'package:equatable/equatable.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import '../../tags/tag_model/tag.dart';
import '../../utils/db_consts.dart';
import '../../utils/maybe.dart';
import 'filter.dart';

class FilterState extends Equatable {
  final Maybe<Filter> filter;
  final List<bool> expandedCategories;
  final List<AppCategory> consolidatedCategories;
  final List<AppCategory> consolidatedSubcategories;
  final Map<String, String> allMembers; //id, name
  final List<Tag> allTags;
  final bool updated;
  final Maybe<String> search;
  final List<Tag> searchedTags;
  final Maybe<SortMethod> sortMethod; //currently unused , implement later

  FilterState({
    required this.filter,
    required this.expandedCategories,
    required this.consolidatedCategories,
    required this.consolidatedSubcategories,
    required this.allMembers,
    required this.allTags,
    required this.updated,
    required this.search,
    required this.searchedTags,
    required this.sortMethod,
  });

  factory FilterState.initial() {
    return FilterState(
      filter: Maybe.none(),
      expandedCategories: const [],
      consolidatedCategories: const [],
      consolidatedSubcategories: const [],
      allMembers: LinkedHashMap(),
      allTags: const [],
      updated: false,
      search: Maybe.none(),
      searchedTags: const [],
      sortMethod: Maybe.none(),
    );
  }

  @override
  List<Object> get props => [
        filter,
        expandedCategories,
        consolidatedCategories,
        consolidatedSubcategories,
        allMembers,
        allTags,
        updated,
        search,
        searchedTags,
        sortMethod,
      ];

  @override
  bool get stringify => true;

  FilterState copyWith({
    Maybe<Filter>? filter,
    List<bool>? expandedCategories,
    List<AppCategory>? consolidatedCategories,
    List<AppCategory>? consolidatedSubcategories,
    Map<String, String>? allMembers,
    List<Tag>? allTags,
    bool? updated,
    Maybe<String>? search,
    List<Tag>? searchedTags,
    Maybe<SortMethod>? sortMethod,
  }) {
    if ((filter == null || identical(filter, this.filter)) &&
        (expandedCategories == null ||
            identical(expandedCategories, this.expandedCategories)) &&
        (consolidatedCategories == null ||
            identical(consolidatedCategories, this.consolidatedCategories)) &&
        (consolidatedSubcategories == null ||
            identical(
                consolidatedSubcategories, this.consolidatedSubcategories)) &&
        (allMembers == null || identical(allMembers, this.allMembers)) &&
        (allTags == null || identical(allTags, this.allTags)) &&
        (updated == null || identical(updated, this.updated)) &&
        (search == null || identical(search, this.search)) &&
        (searchedTags == null || identical(searchedTags, this.searchedTags)) &&
        (sortMethod == null || identical(sortMethod, this.sortMethod))) {
      return this;
    }

    return new FilterState(
      filter: filter ?? this.filter,
      expandedCategories: expandedCategories ?? this.expandedCategories,
      consolidatedCategories:
          consolidatedCategories ?? this.consolidatedCategories,
      consolidatedSubcategories:
          consolidatedSubcategories ?? this.consolidatedSubcategories,
      allMembers: allMembers ?? this.allMembers,
      allTags: allTags ?? this.allTags,
      updated: updated ?? this.updated,
      search: search ?? this.search,
      searchedTags: searchedTags ?? this.searchedTags,
      sortMethod: sortMethod ?? this.sortMethod,
    );
  }
}
