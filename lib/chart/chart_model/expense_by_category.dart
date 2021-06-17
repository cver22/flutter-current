import 'package:equatable/equatable.dart';
import '../../member/member_model/member.dart';

class ExpenseByCategory extends Equatable {
  final DateTime dateTime;
  final String category;
  final String subcategory;
  final Map<String, Member> members;
  final int amount;

  ExpenseByCategory({
    required this.dateTime,
    required this.category,
    required this.subcategory,
    this.members = const <String, Member>{},
    this.amount = 0,
  });

  @override
  List<Object?> get props => [dateTime, category, subcategory, members, amount];

  @override
  bool get stringify => true;

  ExpenseByCategory copyWith({
    DateTime? dateTime,
    String? category,
    String? subcategory,
    Map<String, Member>? members,
    int? amount,
  }) {
    if ((dateTime == null || identical(dateTime, this.dateTime)) &&
        (category == null || identical(category, this.category)) &&
        (subcategory == null || identical(subcategory, this.subcategory)) &&
        (members == null || identical(members, this.members)) &&
        (amount == null || identical(amount, this.amount))) {
      return this;
    }

    return new ExpenseByCategory(
      dateTime: dateTime ?? this.dateTime,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      members: members ?? this.members,
      amount: amount ?? this.amount,
    );
  }
}
