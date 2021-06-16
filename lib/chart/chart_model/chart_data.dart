import 'package:equatable/equatable.dart';

class ChartData extends Equatable {
  final String? categoryName;
  final List<int> amounts;

  ChartData({
    this.categoryName,
    required this.amounts,
  });

  @override
  List<Object?> get props => [categoryName, amounts];

  @override
  bool get stringify => true;

  ChartData copyWith({
    String? categoryName,
    List<int>? amounts,
  }) {
    if ((categoryName == null || identical(categoryName, this.categoryName)) &&
        (amounts == null || identical(amounts, this.amounts))) {
      return this;
    }

    return new ChartData(
      categoryName: categoryName ?? this.categoryName,
      amounts: amounts ?? this.amounts,
    );
  }
}
