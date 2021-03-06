import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import '../../filter/filter_model/filter.dart';
import '../../utils/maybe.dart';
import '../../utils/db_consts.dart';
import 'chart_data.dart';
import 'donut_chart_data.dart';

class ChartState extends Equatable {
  final ChartDateGrouping chartDateGrouping;
  final ChartType chartType;
  final ChartDataGrouping chartDataGrouping;
  final Map<DateTime, ChartData> chartData;
  final List<DonutChartData> donutChartData;
  final List<String> categories;
  final bool loading;
  final bool rebuildChartData; //used to prevent complete rebuild of data for minor chart changes
  final bool showTrendLine;
  final bool showMarkers;
  final DateTime donutStartDate;
  final Maybe<Filter> chartFilter;
  final Map<String, AppEntry> filteredEntries;
  //TODO need rebuildFilteredEntries bool for when entries are created/updated

  ChartState({
    required this.chartDateGrouping,
    required this.chartType,
    required this.chartDataGrouping,
    required this.chartData,
    required this.donutChartData,
    required this.categories,
    required this.loading,
    required this.rebuildChartData,
    required this.showTrendLine,
    required this.showMarkers,
    required this.donutStartDate,
    required this.chartFilter,
    required this.filteredEntries,
  });

  @override
  List<Object?> get props => [
        chartDateGrouping,
        chartType,
        chartDataGrouping,
        chartData,
        donutChartData,
        categories,
        loading,
        rebuildChartData,
        showTrendLine,
        showMarkers,
        donutStartDate,
        chartFilter,
        filteredEntries,
      ];

  @override
  bool get stringify => true;

  factory ChartState.initial() {
    return ChartState(
      chartDateGrouping: ChartDateGrouping.month,
      chartType: ChartType.bar,
      chartDataGrouping: ChartDataGrouping.categories,
      chartData: <DateTime, ChartData>{},
      donutChartData: <DonutChartData>[],
      categories: <String>[],
      loading: true,
      rebuildChartData: true,
      showTrendLine: false,
      showMarkers: false,
      donutStartDate: DateTime.utc(DateTime.now().year, DateTime.now().month),
      chartFilter: Maybe<Filter>.none(),
      filteredEntries: LinkedHashMap(),
    );
  }

  ChartState copyWith({
    ChartDateGrouping? chartDateGrouping,
    ChartType? chartType,
    ChartDataGrouping? chartDataGrouping,
    Map<DateTime, ChartData>? chartData,
    List<DonutChartData>? donutChartData,
    List<String>? categories,
    bool? loading,
    bool? rebuildChartData,
    bool? showTrendLine,
    bool? showMarkers,
    DateTime? donutStartDate,
    Maybe<Filter>? chartFilter,
    Map<String, AppEntry>? filteredEntries,
  }) {
    if ((chartDateGrouping == null || identical(chartDateGrouping, this.chartDateGrouping)) &&
        (chartType == null || identical(chartType, this.chartType)) &&
        (chartDataGrouping == null || identical(chartDataGrouping, this.chartDataGrouping)) &&
        (chartData == null || identical(chartData, this.chartData)) &&
        (donutChartData == null || identical(donutChartData, this.donutChartData)) &&
        (categories == null || identical(categories, this.categories)) &&
        (loading == null || identical(loading, this.loading)) &&
        (rebuildChartData == null || identical(rebuildChartData, this.rebuildChartData)) &&
        (showTrendLine == null || identical(showTrendLine, this.showTrendLine)) &&
        (showMarkers == null || identical(showMarkers, this.showMarkers)) &&
        (donutStartDate == null || identical(donutStartDate, this.donutStartDate)) &&
        (chartFilter == null || identical(chartFilter, this.chartFilter)) &&
        (filteredEntries == null || identical(filteredEntries, this.filteredEntries))) {
      return this;
    }

    return new ChartState(
      chartDateGrouping: chartDateGrouping ?? this.chartDateGrouping,
      chartType: chartType ?? this.chartType,
      chartDataGrouping: chartDataGrouping ?? this.chartDataGrouping,
      chartData: chartData ?? this.chartData,
      donutChartData: donutChartData ?? this.donutChartData,
      categories: categories ?? this.categories,
      loading: loading ?? this.loading,
      rebuildChartData: rebuildChartData ?? this.rebuildChartData,
      showTrendLine: showTrendLine ?? this.showTrendLine,
      showMarkers: showMarkers ?? this.showMarkers,
      donutStartDate: donutStartDate ?? this.donutStartDate,
      chartFilter: chartFilter ?? this.chartFilter,
      filteredEntries: filteredEntries ?? this.filteredEntries,
    );
  }
}
