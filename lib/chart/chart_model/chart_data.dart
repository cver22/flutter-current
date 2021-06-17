import 'package:equatable/equatable.dart';

class ChartData extends Equatable {
  final DateTime? dateTime;
  final List<int> amounts;

  ChartData({
    this.dateTime,
    required this.amounts,
  });

  @override
  List<Object?> get props => [dateTime, amounts];

  @override
  bool get stringify => true;

  ChartData copyWith({
    DateTime? dateTime,
    List<int>? amounts,
  }) {
    if ((dateTime == null || identical(dateTime, this.dateTime)) &&
        (amounts == null || identical(amounts, this.amounts))) {
      return this;
    }

    return new ChartData(
      dateTime: dateTime ?? this.dateTime,
      amounts: amounts ?? this.amounts,
    );
  }
}
