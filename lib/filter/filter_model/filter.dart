import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:expenses/utils/maybe.dart';

class Filter extends Equatable {
  final Maybe<DateTime> startDate;
  final Maybe<DateTime> endDate;
  final Map<String, String> currency; // code, name
  final List<String> selectedCategories; //name
  final List<String> selectedSubcategories; //id
  final Maybe<int> minAmount;
  final Maybe<int> maxAmount;
  final List<String> membersPaid; //id
  final List<String> membersSpent; //id
  final List<String> selectedLogs;
  final List<String> selectedTags;

  Filter({
    this.startDate,
    this.endDate,
    this.currency,
    this.selectedCategories,
    this.selectedSubcategories,
    this.minAmount,
    this.maxAmount,
    this.membersPaid,
    this.membersSpent,
    this.selectedLogs,
    this.selectedTags,
  });

  factory Filter.initial() {
    return Filter(
      startDate: Maybe.none(),
      endDate: Maybe.none(),
      currency: LinkedHashMap(),
      selectedCategories: const [],
      selectedSubcategories: const [],
      minAmount: Maybe.none(),
      maxAmount: Maybe.none(),
      membersPaid: const [],
      membersSpent: const [],
      selectedLogs: const [],
      selectedTags: const [],
    );
  }

  @override
  List<Object> get props => [
        startDate,
        endDate,
        currency,
        selectedCategories,
        selectedSubcategories,
        minAmount,
        maxAmount,
        membersPaid,
        membersSpent,
        selectedLogs,
        selectedTags
      ]; //id, name

  @override
  bool get stringify => true;

  Filter copyWith({
    Maybe<DateTime> startDate,
    Maybe<DateTime> endDate,
    Map<String, String> currency,
    List<String> selectedCategories,
    List<String> selectedSubcategories,
    Maybe<int> minAmount,
    Maybe<int> maxAmount,
    List<String> membersPaid,
    List<String> membersSpent,
    List<String> selectedLogs,
    List<String> selectedTags,
  }) {
    if ((startDate == null || identical(startDate, this.startDate)) &&
        (endDate == null || identical(endDate, this.endDate)) &&
        (currency == null || identical(currency, this.currency)) &&
        (selectedCategories == null || identical(selectedCategories, this.selectedCategories)) &&
        (selectedSubcategories == null || identical(selectedSubcategories, this.selectedSubcategories)) &&
        (minAmount == null || identical(minAmount, this.minAmount)) &&
        (maxAmount == null || identical(maxAmount, this.maxAmount)) &&
        (membersPaid == null || identical(membersPaid, this.membersPaid)) &&
        (membersSpent == null || identical(membersSpent, this.membersSpent)) &&
        (selectedLogs == null || identical(selectedLogs, this.selectedLogs)) &&
        (selectedTags == null || identical(selectedTags, this.selectedTags))) {
      return this;
    }

    return new Filter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currency: currency ?? this.currency,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedSubcategories: selectedSubcategories ?? this.selectedSubcategories,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      membersPaid: membersPaid ?? this.membersPaid,
      membersSpent: membersSpent ?? this.membersSpent,
      selectedLogs: selectedLogs ?? this.selectedLogs,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}
