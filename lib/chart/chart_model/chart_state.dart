import 'package:equatable/equatable.dart';
import '../../utils/db_consts.dart';
import 'chart_data.dart';

class ChartState extends Equatable {
  final ChartDateGrouping chartDateGrouping;
  final ChartType chartType;
  final ChartDataGrouping chartDataGrouping;
  final Map<DateTime, ChartData> chartData;
  final List<String> categories;
  final bool loading;
  final bool rebuildChartData; //used to prevent complete rebuild of data for minor chart changes

  ChartState({
    required this.chartDateGrouping,
    required this.chartType,
    required this.chartDataGrouping,
    required this.chartData,
    required this.categories,
    required this.loading,
    required this.rebuildChartData,

  });

  @override
  List<Object?> get props => [chartDateGrouping, chartType, chartDataGrouping, chartData, categories, loading, rebuildChartData];

  @override
  bool get stringify => true;

  factory ChartState.initial() {
    return ChartState(
      chartDateGrouping: ChartDateGrouping.month,
      chartType: ChartType.bar,
      chartDataGrouping: ChartDataGrouping.categories,
      chartData: <DateTime, ChartData>{},
      categories: <String>[],
      loading: false,
      rebuildChartData: true,
    );
  }

  ChartState copyWith({
    ChartDateGrouping? chartDateGrouping,
    ChartType? chartType,
    ChartDataGrouping? chartDataGrouping,
    Map<DateTime, ChartData>? chartData,
    List<String>? categories,
    bool? loading,
    bool? rebuildChartData,
  }) {
    if ((chartDateGrouping == null || identical(chartDateGrouping, this.chartDateGrouping)) &&
        (chartType == null || identical(chartType, this.chartType)) &&
        (chartDataGrouping == null || identical(chartDataGrouping, this.chartDataGrouping)) &&
        (chartData == null || identical(chartData, this.chartData)) &&
        (categories == null || identical(categories, this.categories)) &&
        (loading == null || identical(loading, this.loading)) &&
        (rebuildChartData == null || identical(rebuildChartData, this.rebuildChartData))) {
      return this;
    }

    return new ChartState(
      chartDateGrouping: chartDateGrouping ?? this.chartDateGrouping,
      chartType: chartType ?? this.chartType,
      chartDataGrouping: chartDataGrouping ?? this.chartDataGrouping,
      chartData: chartData ?? this.chartData,
      categories: categories ?? this.categories,
      loading: loading ?? this.loading,
      rebuildChartData: rebuildChartData ?? this.rebuildChartData,
    );
  }
}
