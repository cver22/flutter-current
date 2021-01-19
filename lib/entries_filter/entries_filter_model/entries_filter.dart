import 'package:equatable/equatable.dart';

class EntriesFilter extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> logId; //id, name
  final Map<String, String> currency; // code, name
  final List<String> categories;
  final List<String> subcategories;
  final int minAmount;
  final int maxAmount;
  final List<String> logMembers; //id
  final List<String> tags;

  EntriesFilter(
      {this.startDate,
      this.endDate,
      this.logId = const [],
      this.currency = const {},
      this.categories = const [],
      this.subcategories = const [],
      this.minAmount,
      this.maxAmount,
      this.logMembers = const [],
      this.tags = const []});

  @override
  List<Object> get props => [
        startDate,
        endDate,
        logId,
        currency,
        categories,
        subcategories,
        minAmount,
        maxAmount,
        logMembers,
        tags
      ]; //id, name

  @override
  bool get stringify => true;

  EntriesFilter copyWith({
    DateTime startDate,
    DateTime endDate,
    List<String> logId,
    Map<String, String> currency,
    List<String> categories,
    List<String> subcategories,
    int minAmount,
    int maxAmount,
    List<String> logMembers,
    List<String> tags,
  }) {
    if ((startDate == null || identical(startDate, this.startDate)) &&
        (endDate == null || identical(endDate, this.endDate)) &&
        (logId == null || identical(logId, this.logId)) &&
        (currency == null || identical(currency, this.currency)) &&
        (categories == null || identical(categories, this.categories)) &&
        (subcategories == null || identical(subcategories, this.subcategories)) &&
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
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      logMembers: logMembers ?? this.logMembers,
      tags: tags ?? this.tags,
    );
  }
}
