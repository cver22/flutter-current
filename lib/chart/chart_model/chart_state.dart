import 'package:equatable/equatable.dart';
import '../../chart/chart_model/expense_by_category.dart';
import '../../utils/db_consts.dart';
import 'chart_data.dart';

class ChartState extends Equatable {
  final ChartGrouping chartGrouping;
  final ChartType chartType;
  final List<ExpenseByCategory> expenseByCategory;
  final List<ChartData> chartData;
  final List<String> categories;

  ChartState({
    required this.chartGrouping,
    required this.chartType,
    required this.expenseByCategory,
    required this.chartData,
    required this.categories,
  });

  @override
  List<Object?> get props => [chartGrouping, chartType, expenseByCategory, chartData, categories];

  @override
  bool get stringify => true;

  factory ChartState.initial() {
    return ChartState(
      chartGrouping: ChartGrouping.month,
      chartType: ChartType.bar,
      expenseByCategory: const <ExpenseByCategory>[],
      chartData: <ChartData>[],
      categories: <String>[],
    );
  }

  ChartState copyWith({
    ChartGrouping? chartGrouping,
    ChartType? chartType,
    List<ExpenseByCategory>? expenseByCategory,
    List<ChartData>? chartData,
    List<String>? categories,
  }) {
    if ((chartGrouping == null || identical(chartGrouping, this.chartGrouping)) &&
        (chartType == null || identical(chartType, this.chartType)) &&
        (expenseByCategory == null || identical(expenseByCategory, this.expenseByCategory)) &&
        (chartData == null || identical(chartData, this.chartData)) &&
        (categories == null || identical(categories, this.categories))) {
      return this;
    }

    return new ChartState(
      chartGrouping: chartGrouping ?? this.chartGrouping,
      chartType: chartType ?? this.chartType,
      expenseByCategory: expenseByCategory ?? this.expenseByCategory,
      chartData: chartData ?? this.chartData,
      categories: categories ?? this.categories,
    );
  }
}
