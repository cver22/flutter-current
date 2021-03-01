import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';

class FilterState extends Equatable {
  final Maybe<Filter> filter;
  final List<bool> expandedCategories;
  final List<AppCategory> allCategories;
  final List<AppCategory> allSubcategories;
  final Map<String, String> allMembers; //id, name
  final List<Tag> allTags;
  final bool updated;

  FilterState({
    this.filter,
    this.expandedCategories,
    this.allCategories,
    this.allSubcategories,
    this.allMembers,
    this.allTags,
    this.updated,
  });

  factory FilterState.initial() {
    return FilterState(
      filter: Maybe.none(),
      expandedCategories: List(),
      allCategories: const [],
      allSubcategories: const [],
      allMembers: LinkedHashMap(),
      allTags: const [],
      updated: false,
    );
  }

  @override
  List<Object> get props => [
        filter,
        expandedCategories,
        allCategories,
        allSubcategories,
        allMembers,
        allTags,
        updated,
      ];

  @override
  bool get stringify => true;

  FilterState copyWith({
    Maybe<Filter> filter,
    List<bool> expandedCategories,
    List<AppCategory> allCategories,
    List<AppCategory> allSubcategories,
    Map<String, String> allMembers,
    List<Tag> allTags,
    bool updated,
  }) {
    if ((filter == null || identical(filter, this.filter)) &&
        (expandedCategories == null || identical(expandedCategories, this.expandedCategories)) &&
        (allCategories == null || identical(allCategories, this.allCategories)) &&
        (allSubcategories == null || identical(allSubcategories, this.allSubcategories)) &&
        (allMembers == null || identical(allMembers, this.allMembers)) &&
        (allTags == null || identical(allTags, this.allTags)) &&
        (updated == null || identical(updated, this.updated))) {
      return this;
    }

    return new FilterState(
      filter: filter ?? this.filter,
      expandedCategories: expandedCategories ?? this.expandedCategories,
      allCategories: allCategories ?? this.allCategories,
      allSubcategories: allSubcategories ?? this.allSubcategories,
      allMembers: allMembers ?? this.allMembers,
      allTags: allTags ?? this.allTags,
      updated: updated ?? this.updated,
    );
  }
}
