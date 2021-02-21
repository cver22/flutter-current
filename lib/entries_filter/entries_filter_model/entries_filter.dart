import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/utils/maybe.dart';

class EntriesFilter extends Equatable {
  final Maybe<DateTime> startDate;
  final Maybe<DateTime> endDate;
  final List<String> logId; //id, name
  final Map<String, String> currency; // code, name
  final Map<String, bool> selectedCategories;
  final Map<String, bool> selectedSubcategories;
  final List<AppCategory> allCategories;
  final List<AppCategory> allSubcategories;
  final Maybe<int> minAmount;
  final Maybe<int> maxAmount;
  final List<String> logMembers; //id
  final List<String> tags;

  EntriesFilter({
    this.startDate,
    this.endDate,
    this.logId,
    this.currency,
    this.selectedCategories,
    this.selectedSubcategories,
    this.allCategories,
    this.allSubcategories,
    this.minAmount,
    this.maxAmount,
    this.logMembers,
    this.tags,
  });

  factory EntriesFilter.initial() {
    return EntriesFilter(
      startDate: Maybe.none(),
      endDate: Maybe.none(),
      logId: const [],
      currency: LinkedHashMap(),
      selectedCategories: LinkedHashMap(),
      selectedSubcategories: LinkedHashMap(),
      allCategories: const [],
      allSubcategories: const [],
      minAmount: Maybe.none(),
      maxAmount: Maybe.none(),
      logMembers: const [],
      tags: const [],
    );
  }

  @override
  List<Object> get props => [
        startDate,
        endDate,
        logId,
        currency,
        selectedCategories,
        selectedSubcategories,
        allCategories,
        allSubcategories,
        minAmount,
        maxAmount,
        logMembers,
        tags
      ]; //id, name

  @override
  bool get stringify => true;

  EntriesFilter copyWith({
    Maybe<DateTime> startDate,
    Maybe<DateTime> endDate,
    List<String> logId,
    Map<String, String> currency,
    Map<String, bool> selectedCategories,
    Map<String, bool> selectedSubcategories,
    List<AppCategory> allCategories,
    List<AppCategory> allSubcategories,
    Maybe<int> minAmount,
    Maybe<int> maxAmount,
    List<String> logMembers,
    List<String> tags,
  }) {
    if ((startDate == null || identical(startDate, this.startDate)) &&
        (endDate == null || identical(endDate, this.endDate)) &&
        (logId == null || identical(logId, this.logId)) &&
        (currency == null || identical(currency, this.currency)) &&
        (selectedCategories == null || identical(selectedCategories, this.selectedCategories)) &&
        (selectedSubcategories == null || identical(selectedSubcategories, this.selectedSubcategories)) &&
        (allCategories == null || identical(allCategories, this.allCategories)) &&
        (allSubcategories == null || identical(allSubcategories, this.allSubcategories)) &&
        (minAmount == null || identical(minAmount, this.minAmount)) &&
        (maxAmount == null || identical(maxAmount, this.maxAmount)) &&
        (logMembers == null || identical(logMembers, this.logMembers)) &&
        (tags == null || identical(tags, this.tags))) {
      return this;
    }

    return new EntriesFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      logId: logId ?? this.logId,
      currency: currency ?? this.currency,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedSubcategories: selectedSubcategories ?? this.selectedSubcategories,
      allCategories: allCategories ?? this.allCategories,
      allSubcategories: allSubcategories ?? this.allSubcategories,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      logMembers: logMembers ?? this.logMembers,
      tags: tags ?? this.tags,
    );
  }
}
