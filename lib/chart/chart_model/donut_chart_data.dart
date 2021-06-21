import 'package:equatable/equatable.dart';

class DonutChartData extends Equatable {
  final String category;
  final int amount;
  final String text;

  DonutChartData({required this.category, this.amount = 0, this.text = ''});

  @override
  List<Object?> get props => [category, amount, text];

  @override
  bool get stringify => true;

  DonutChartData copyWith({
    String? category,
    int? amount,
    String? text,
  }) {
    if ((category == null || identical(category, this.category)) &&
        (amount == null || identical(amount, this.amount)) &&
        (text == null || identical(text, this.text))) {
      return this;
    }

    return new DonutChartData(
      category: category ?? this.category,
      amount: amount ?? this.amount,
      text: text ?? this.text,
    );
  }
}