import 'package:equatable/equatable.dart';
import '../../utils/db_consts.dart';
import 'chart_data.dart';

class ChartState extends Equatable {
  final ChartGrouping chartGrouping;
  final ChartType chartType;
  final List<ChartData> chartData;
  final List<String> categories;
  final bool loading;

  ChartState({
    required this.chartGrouping,
    required this.chartType,
    required this.chartData,
    required this.categories,
    required this.loading,
  });

  @override
  List<Object?> get props => [chartGrouping, chartType, chartData, categories, loading];

  @override
  bool get stringify => true;

  factory ChartState.initial() {
    return ChartState(
      chartGrouping: ChartGrouping.month,
      chartType: ChartType.bar,
      chartData: <ChartData>[],
      categories: <String>[],
      loading: false,
    );
  }

  ChartState copyWith({
    ChartGrouping? chartGrouping,
    ChartType? chartType,
    List<ChartData>? chartData,
    List<String>? categories,
    bool? loading,
  }) {
    if ((chartGrouping == null || identical(chartGrouping, this.chartGrouping)) &&
        (chartType == null || identical(chartType, this.chartType)) &&
        (chartData == null || identical(chartData, this.chartData)) &&
        (categories == null || identical(categories, this.categories)) &&
        (loading == null || identical(loading, this.loading))) {
      return this;
    }

    return new ChartState(
      chartGrouping: chartGrouping ?? this.chartGrouping,
      chartType: chartType ?? this.chartType,
      chartData: chartData ?? this.chartData,
      categories: categories ?? this.categories,
      loading: loading ?? this.loading,
    );
  }
}
