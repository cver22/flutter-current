import 'package:equatable/equatable.dart';
import '../../utils/maybe.dart';
import '../../chart/chart_model/expense_by_category.dart';
import '../../utils/db_consts.dart';
import 'chart_data.dart';

class ChartState extends Equatable {
  final ChartGrouping chartGrouping;
  final ChartType chartType;
  final List<ExpenseByCategory> expenseByCategory;
  final List<ChartData> chartData;
  final List<String> chartPeriods;

  ChartState({
    required this.chartGrouping,
    required this.chartType,
    required this.expenseByCategory,
    required this.chartData,
    required this.chartPeriods,
  });

  @override
  List<Object?> get props => [chartGrouping, chartType, expenseByCategory];

  @override
  bool get stringify => true;

  factory ChartState.initial() {
    return ChartState(
      chartGrouping: ChartGrouping.month,
      chartType: ChartType.bar,
      expenseByCategory: const <ExpenseByCategory>[],
      chartData: <ChartData>[],
      chartPeriods: <String>[],
    );
  }

  ChartState copyWith({
    ChartGrouping? chartGrouping,
    ChartType? chartType,
    List<ExpenseByCategory>? expenseByCategory,
    List<ChartData>? chartData,
    List<String>? chartPeriods,
  }) {
    if ((chartGrouping == null || identical(chartGrouping, this.chartGrouping)) &&
        (chartType == null || identical(chartType, this.chartType)) &&
        (expenseByCategory == null || identical(expenseByCategory, this.expenseByCategory)) &&
        (chartData == null || identical(chartData, this.chartData)) &&
        (chartPeriods == null || identical(chartPeriods, this.chartPeriods))) {
      return this;
    }

    return new ChartState(
      chartGrouping: chartGrouping ?? this.chartGrouping,
      chartType: chartType ?? this.chartType,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      chartData: chartData ?? this.chartData,
      chartPeriods: chartPeriods ?? this.chartPeriods,
    );
  }
}
