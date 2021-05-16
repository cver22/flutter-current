import 'package:equatable/equatable.dart';

import '../../utils/maybe.dart';

class Filter extends Equatable {
  final Maybe<DateTime?> startDate;
  final Maybe<DateTime?> endDate;
  final List<String> selectedCurrencies; // code
  final List<String> selectedCategories; //name
  final List<String> selectedSubcategories; //id
  final Maybe<int?> minAmount;
  final Maybe<int?> maxAmount;
  final List<String> membersPaid; //id
  final List<String> membersSpent; //id
  final List<String> selectedLogs;
  final List<String> selectedTags;

  Filter({
    required this.startDate,
    required this.endDate,
    required this.selectedCurrencies,
    required this.selectedCategories,
    required this.selectedSubcategories,
    required this.minAmount,
    required this.maxAmount,
    required this.membersPaid,
    required this.membersSpent,
    required this.selectedLogs,
    required this.selectedTags,
  });

  factory Filter.initial() {
    return Filter(
      startDate: Maybe<DateTime>.none(),
      endDate: Maybe<DateTime>.none(),
      selectedCurrencies: const <String>[],
      selectedCategories: const <String>[],
      selectedSubcategories: const <String>[],
      minAmount: Maybe<int>.none(),
      maxAmount: Maybe<int>.none(),
      membersPaid: const <String>[],
      membersSpent: const <String>[],
      selectedLogs: const <String>[],
      selectedTags: const <String>[],
    );
  }

  @override
  List<Object> get props => [
        startDate,
        endDate,
        selectedCurrencies,
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
    Maybe<DateTime?>? startDate,
    Maybe<DateTime?>? endDate,
    List<String>? selectedCurrencies,
    List<String>? selectedCategories,
    List<String>? selectedSubcategories,
    Maybe<int?>? minAmount,
    Maybe<int?>? maxAmount,
    List<String>? membersPaid,
    List<String>? membersSpent,
    List<String>? selectedLogs,
    List<String>? selectedTags,
  }) {
    if ((startDate == null || identical(startDate, this.startDate)) &&
        (endDate == null || identical(endDate, this.endDate)) &&
        (selectedCurrencies == null || identical(selectedCurrencies, this.selectedCurrencies)) &&
        (selectedCategories == null ||
            identical(selectedCategories, this.selectedCategories)) &&
        (selectedSubcategories == null ||
            identical(selectedSubcategories, this.selectedSubcategories)) &&
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
      selectedCurrencies: selectedCurrencies ?? this.selectedCurrencies,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedSubcategories:
          selectedSubcategories ?? this.selectedSubcategories,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      membersPaid: membersPaid ?? this.membersPaid,
      membersSpent: membersSpent ?? this.membersSpent,
      selectedLogs: selectedLogs ?? this.selectedLogs,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}
