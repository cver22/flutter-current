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
  final List<String> usedCurrencies;
  final bool updated;
  final Maybe<String> tagSearch;
  final List<Tag> searchedTags;
  final Maybe<SortMethod> sortMethod; //currently unused , implement later

  FilterState({
    required this.filter,
    required this.expandedCategories,
    required this.consolidatedCategories,
    required this.consolidatedSubcategories,
    required this.allMembers,
    required this.allTags,
    required this.usedCurrencies,
    required this.updated,
    required this.tagSearch,
    required this.searchedTags,
    required this.sortMethod,
  });

  factory FilterState.initial() {
    return FilterState(
      filter: Maybe.none(),
      expandedCategories: const <bool>[],
      consolidatedCategories: const <AppCategory>[],
      consolidatedSubcategories: const <AppCategory>[],
      allMembers: LinkedHashMap(),
      allTags: const <Tag>[],
      usedCurrencies: const <String>[],
      updated: false,
      tagSearch: Maybe.none(),
      searchedTags: const <Tag>[],
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
        tagSearch,
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
    List<String>? usedCurrencies,
    bool? updated,
    Maybe<String>? tagSearch,
    List<Tag>? searchedTags,
    Maybe<SortMethod>? sortMethod,
  }) {
    if ((filter == null || identical(filter, this.filter)) &&
        (expandedCategories == null || identical(expandedCategories, this.expandedCategories)) &&
        (consolidatedCategories == null || identical(consolidatedCategories, this.consolidatedCategories)) &&
        (consolidatedSubcategories == null || identical(consolidatedSubcategories, this.consolidatedSubcategories)) &&
        (allMembers == null || identical(allMembers, this.allMembers)) &&
        (allTags == null || identical(allTags, this.allTags)) &&
        (usedCurrencies == null || identical(usedCurrencies, this.usedCurrencies)) &&
        (updated == null || identical(updated, this.updated)) &&
        (tagSearch == null || identical(tagSearch, this.tagSearch)) &&
        (searchedTags == null || identical(searchedTags, this.searchedTags)) &&
        (sortMethod == null || identical(sortMethod, this.sortMethod))) {
      return this;
    }

    return new FilterState(
      filter: filter ?? this.filter,
      expandedCategories: expandedCategories ?? this.expandedCategories,
      consolidatedCategories: consolidatedCategories ?? this.consolidatedCategories,
      consolidatedSubcategories: consolidatedSubcategories ?? this.consolidatedSubcategories,
      allMembers: allMembers ?? this.allMembers,
      allTags: allTags ?? this.allTags,
      usedCurrencies: usedCurrencies ?? this.usedCurrencies,
      updated: updated ?? this.updated,
      tagSearch: tagSearch ?? this.tagSearch,
      searchedTags: searchedTags ?? this.searchedTags,
      sortMethod: sortMethod ?? this.sortMethod,
    );
  }
}
