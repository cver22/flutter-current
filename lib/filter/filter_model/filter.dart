import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:expenses/utils/maybe.dart';

class Filter extends Equatable {
  final Maybe<DateTime> startDate;
  final Maybe<DateTime> endDate;
  final Map<String, String> currency; // code, name
  final List<String> selectedCategoryNames; //name
  final List<String> selectedSubcategoryIds; //id
  final Maybe<int> minAmount;
  final Maybe<int> maxAmount;
  final List<String> membersPaid; //id
  final List<String> membersSpent; //id
  final List<String> selectedLogs;
  final List<String> tags;

  Filter({
    this.startDate,
    this.endDate,
    this.currency,
    this.selectedCategoryNames,
    this.selectedSubcategoryIds,
    this.minAmount,
    this.maxAmount,
    this.membersPaid,
    this.membersSpent,
    this.selectedLogs,
    this.tags,
  });

  factory Filter.initial() {
    return Filter(
      startDate: Maybe.none(),
      endDate: Maybe.none(),
      currency: LinkedHashMap(),
      selectedCategoryNames: const [],
      selectedSubcategoryIds: const [],
      minAmount: Maybe.none(),
      maxAmount: Maybe.none(),
      membersPaid: const [],
      membersSpent: const [],
      selectedLogs: const [],
      tags: const [],
    );
  }

  @override
  List<Object> get props => [
        startDate,
        endDate,
        currency,
        selectedCategoryNames,
        selectedSubcategoryIds,
        minAmount,
        maxAmount,
        membersPaid,
        membersSpent,
        selectedLogs,
        tags
      ]; //id, name

  @override
  bool get stringify => true;

  Filter copyWith({
    Maybe<DateTime> startDate,
    Maybe<DateTime> endDate,
    Map<String, String> currency,
    List<String> selectedCategoryNames,
    List<String> selectedSubcategoryIds,
    Maybe<int> minAmount,
    Maybe<int> maxAmount,
    List<String> membersPaid,
    List<String> membersSpent,
    List<String> selectedLogs,
    List<String> tags,
  }) {
    if ((startDate == null || identical(startDate, this.startDate)) &&
        (endDate == null || identical(endDate, this.endDate)) &&
        (currency == null || identical(currency, this.currency)) &&
        (selectedCategoryNames == null || identical(selectedCategoryNames, this.selectedCategoryNames)) &&
        (selectedSubcategoryIds == null || identical(selectedSubcategoryIds, this.selectedSubcategoryIds)) &&
        (minAmount == null || identical(minAmount, this.minAmount)) &&
        (maxAmount == null || identical(maxAmount, this.maxAmount)) &&
        (membersPaid == null || identical(membersPaid, this.membersPaid)) &&
        (membersSpent == null || identical(membersSpent, this.membersSpent)) &&
        (selectedLogs == null || identical(selectedLogs, this.selectedLogs)) &&
        (tags == null || identical(tags, this.tags))) {
      return this;
    }

    return new Filter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currency: currency ?? this.currency,
      selectedCategoryNames: selectedCategoryNames ?? this.selectedCategoryNames,
      selectedSubcategoryIds: selectedSubcategoryIds ?? this.selectedSubcategoryIds,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      membersPaid: membersPaid ?? this.membersPaid,
      membersSpent: membersSpent ?? this.membersSpent,
      selectedLogs: selectedLogs ?? this.selectedLogs,
      tags: tags ?? this.tags,
    );
  }
}
