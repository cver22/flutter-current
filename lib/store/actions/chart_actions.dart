import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/chart/chart_model/donut_chart_data.dart';
import 'package:expenses/currency/currency_utils/currency_formatters.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/maybe.dart';

import '../../chart/chart_model/chart_data.dart';
import '../../log/log_model/log.dart';
import '../../utils/db_consts.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../chart/chart_model/chart_state.dart';
import '../../app/models/app_state.dart';
import 'app_actions.dart';

AppState Function(AppState) updateChartState(ChartState update(chartState)) {
  return (state) => state.copyWith(chartState: update(state.chartState));
}

class ChartUpdateData implements AppAction {
  final ChartDateGrouping? chartDateGrouping;
  final ChartDataGrouping? chartDataGrouping;
  final ChartType? chartType;
  final bool? rebuildChartData;
  final DateTime? donutStartDate;
  final bool clearFilter;

  ChartUpdateData({
    this.chartDateGrouping,
    this.chartDataGrouping,
    this.chartType,
    this.rebuildChartData,
    this.donutStartDate,
    this.clearFilter = false,
  });

  @override
  AppState updateState(AppState appState) {
    Map<String, AppEntry> entries = Map<String, AppEntry>.from(appState.entriesState.entries);
    ChartDateGrouping dateGrouping = chartDateGrouping ?? appState.chartState.chartDateGrouping;
    ChartDataGrouping dataGrouping = chartDataGrouping ?? appState.chartState.chartDataGrouping;
    ChartType type = chartType ?? appState.chartState.chartType;
    Map<DateTime, ChartData> chartMap = Map<DateTime, ChartData>.from(appState.chartState.chartData);
    List<String> categoriesList = List<String>.from(appState.chartState.categories);
    Map<String, Log> logs = Map<String, Log>.from(appState.logsState.logs);
    Map<String, String> categoriesMap = <String, String>{};
    bool rebuildData = rebuildChartData ?? appState.chartState.rebuildChartData;
    DateTime startDate = donutStartDate ?? appState.chartState.donutStartDate;
    DateTime donutEndDate = DateTime.now();
    Map<String, DonutChartData> donutChartMap = <String, DonutChartData>{};
    Maybe<Filter> chartFilter = clearFilter ? Maybe<Filter>.none() : appState.chartState.chartFilter;

    if (chartFilter.isSome) {
      entries = Map<String, AppEntry>.of(appState.chartState.filteredEntries);
    }

    if (dateGrouping != appState.chartState.chartDateGrouping ||
        dataGrouping != appState.chartState.chartDataGrouping ||
        rebuildData) {
      chartMap = <DateTime, ChartData>{};
      categoriesList = <String>[];

      //if the chart type is a donut, set the date grouping
      if (type == ChartType.donut) {
        if (dateGrouping == ChartDateGrouping.day) {
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          donutEndDate = DateTime(startDate.year, startDate.month, startDate.day + 1);
        } else if (dateGrouping == ChartDateGrouping.month) {
          startDate = DateTime(startDate.year, startDate.month);
          donutEndDate = DateTime(startDate.year, startDate.month + 1);
        } else {
          startDate = DateTime(startDate.year);
          donutEndDate = DateTime(startDate.year + 1);
        }
      }

      //if the data is grouped by category or subcategory, create a map of all categories and subcategories from the logs
      logs.forEach((key, log) {
        if (dataGrouping == ChartDataGrouping.categories) {
          log.categories.forEach((category) {
            if (!categoriesMap.containsKey(category.id) && category.id != TRANSFER_FUNDS) {
              categoriesMap.putIfAbsent(category.id!, () => category.name!);
            }
          });
        } else if (dataGrouping == ChartDataGrouping.subcategories) {
          log.subcategories.forEach((subcategory) {
            if (!categoriesMap.containsKey(subcategory.id)) {
              categoriesMap.putIfAbsent(subcategory.id!, () => subcategory.name!);
            }
          });
          categoriesMap.putIfAbsent(NO_SUBCATEGORY, () => 'No Subcategory');
        } else {
          categoriesMap.putIfAbsent('total', () => 'Total');
        }
      });

      //list all categories or subcategories and prevent duplication of the category map names
      if (dataGrouping != ChartDataGrouping.total) {
        entries.forEach((key, entry) {
          if (entry.categoryId != TRANSFER_FUNDS) {
            String? category;

            if (dataGrouping == ChartDataGrouping.categories) {
              category = categoriesMap[entry.categoryId!]!;
            } else if (dataGrouping == ChartDataGrouping.subcategories) {
              category = categoriesMap[entry.subcategoryId ?? NO_SUBCATEGORY]!;
            }

            if (!categoriesList.contains(category)) {
              categoriesList.add(category!);
            }
          }
        });
      } else {
        categoriesList.add(categoriesMap['total']!);
      }

      //TODO sort this to match the log category order
      categoriesList.sort();

      //chart data base to contain array of the same size at the number of categories
      List<int> amounts = <int>[];

      categoriesList.forEach((category) {
        amounts.add(0);
        donutChartMap.putIfAbsent(category, () => DonutChartData(category: category));
      });

      ChartData chartDataBase = ChartData(amounts: amounts);

      entries.forEach((key, entry) {
        if (entry.categoryId != TRANSFER_FUNDS) {
          DateTime entryDateTime = DateTime(entry.dateTime.year);
          bool inDonutRange = false;
          if (dateGrouping == ChartDateGrouping.day) {
            entryDateTime = DateTime(entry.dateTime.year, entry.dateTime.month, entry.dateTime.day);
          } else if (dateGrouping == ChartDateGrouping.month) {
            entryDateTime = DateTime(entry.dateTime.year, entry.dateTime.month);
          }

          if (entryDateTime.isAtSameMomentAs(startDate) && entryDateTime.isBefore(donutEndDate)) {
            inDonutRange = true;
          }

          if (type == ChartType.donut && inDonutRange) {
            donutChartMap.update(categoriesMap[entry.categoryId!]!, (value) {
              int newAmount = value.amount + entry.amount;

              return value.copyWith(
                  amount: newAmount,
                  text: formattedAmount(
                    currency: CurrencyService().findByCode('USD')!,
                    value: newAmount,
                  ));
            });
          } else if (type != ChartType.donut) {
            int categoryIndex = 0;
            if (dataGrouping == ChartDataGrouping.categories) {
              categoryIndex = categoriesList.indexOf(categoriesMap[entry.categoryId!]!);
            } else if (dataGrouping == ChartDataGrouping.subcategories) {
              categoryIndex = categoriesList.indexOf(categoriesMap[entry.subcategoryId ?? NO_SUBCATEGORY]!);
            }

            int chartDataAmount = 0;
            List<int> seriesAmounts = <int>[];
            ChartData chartData = chartDataBase;
            bool newSeries = true;

            if (chartMap.containsKey(entryDateTime)) {
              chartData = chartMap[entryDateTime]!;
              seriesAmounts = List<int>.from(chartData.amounts);
              chartDataAmount = entry.amount + seriesAmounts[categoryIndex];
              seriesAmounts.removeAt(categoryIndex);
              newSeries = false;

              chartData = chartData.copyWith(amounts: seriesAmounts);
            } else {
              seriesAmounts = List<int>.from(chartDataBase.amounts);
              chartDataAmount = entry.amount;
              seriesAmounts.removeAt(categoryIndex);
            }

            //remove the existing data from the seriesAmounts
            if (categoryIndex > seriesAmounts.length) {
              seriesAmounts.add(chartDataAmount);
            } else {
              seriesAmounts.insert(categoryIndex, chartDataAmount);
            }

            //if date grouping is new, add with date
            if (newSeries) {
              chartData = chartData.copyWith(amounts: seriesAmounts, dateTime: entryDateTime);
            } else {
              chartData = chartData.copyWith(amounts: seriesAmounts);
            }
            chartMap.update(entryDateTime, (v) => chartData, ifAbsent: () => chartData);
          }
        }
      });
    }

    return updateSubstates(
      appState,
      [
        updateChartState((chartState) => chartState.copyWith(
              categories: categoriesList,
              chartData: chartMap,
              donutChartData: donutChartMap.values.toList(),
              chartType: type,
              chartDateGrouping: dateGrouping,
              chartDataGrouping: dataGrouping,
              rebuildChartData: false,
              loading: false,
              chartFilter: chartFilter,
              filteredEntries: clearFilter ? <String, AppEntry>{} : appState.chartState.filteredEntries,
            )),
      ],
    );
  }
}

class ChartSetOptions implements AppAction {
  final ChartDateGrouping? chartDateGrouping;
  final ChartDataGrouping? chartDataGrouping;
  final ChartType? chartType;
  final bool? showTrendLine;
  final bool? showMarkers;

  ChartSetOptions({
    this.chartDateGrouping,
    this.chartDataGrouping,
    this.chartType,
    this.showTrendLine,
    this.showMarkers,
  });

  @override
  AppState updateState(AppState appState) {
    ChartDateGrouping dateGrouping = chartDateGrouping ?? appState.chartState.chartDateGrouping;
    ChartDataGrouping dataGrouping = chartDataGrouping ?? appState.chartState.chartDataGrouping;
    ChartType type = chartType ?? appState.chartState.chartType;
    bool showTrend = showTrendLine ?? appState.chartState.showTrendLine;
    bool markers = showMarkers ?? appState.chartState.showMarkers;

    return updateSubstates(
      appState,
      [
        updateChartState((chartState) => chartState.copyWith(
              chartType: type,
              chartDateGrouping: dateGrouping,
              chartDataGrouping: dataGrouping,
              showTrendLine: showTrend,
              showMarkers: markers,
              rebuildChartData: true,
              loading: true,
            )),
      ],
    );
  }
}

class ChartSetLoading implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateChartState((chartState) => chartState.copyWith(
              loading: true,
            )),
      ],
    );
  }
}

class ChartShowTrendLine implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateChartState((chartState) => chartState.copyWith(
              showTrendLine: !appState.chartState.showTrendLine,
            )),
      ],
    );
  }
}

class ChartIncrementDecrementDonutDate implements AppAction {
  final bool increment;

  ChartIncrementDecrementDonutDate({this.increment = false});

  @override
  AppState updateState(AppState appState) {
    ChartDateGrouping dateGrouping = appState.chartState.chartDateGrouping;
    DateTime donutStartDate = appState.chartState.donutStartDate;
    int adjustment = increment ? 1 : -1;

    if (dateGrouping == ChartDateGrouping.day) {
      donutStartDate = DateTime(donutStartDate.year, donutStartDate.month, donutStartDate.day + adjustment);
    } else if (dateGrouping == ChartDateGrouping.month) {
      donutStartDate = DateTime(donutStartDate.year, donutStartDate.month + adjustment);
    } else {
      donutStartDate = DateTime(donutStartDate.year + adjustment);
    }

    return updateSubstates(
      appState,
      [
        updateChartState((chartState) => chartState.copyWith(
              donutStartDate: donutStartDate,
              rebuildChartData: true,
            )),
      ],
    );
  }
}

class ChartSetChartFilter implements AppAction {
  final String? logId;

  ChartSetChartFilter({this.logId});

  @override
  AppState updateState(AppState appState) {
    FilterState filterState = appState.filterState;
    Map<String, AppEntry> filteredEntries = <String, AppEntry>{};

    Maybe<Filter> updatedFilter = Maybe<Filter>.some(Filter.initial());

    if (logId == null) {
      //if filter has been changed, save new filter, if reset, pass no filter
      updatedFilter = filterState.updated ? filterState.filter : Maybe<Filter>.none();
    } else {
      //filter was set fro a logListTile and should only filter based on the log
      List<String> selectedLogs = [];
      selectedLogs.add(logId!);
      updatedFilter = Maybe<Filter>.some(updatedFilter.value.copyWith(selectedLogs: selectedLogs));
    }

    filteredEntries = buildFilteredEntries(
      entries: appState.entriesState.entries.values.toList(),
      filter: updatedFilter.value,
      logs: Map<String, Log>.of(appState.logsState.logs),
      allTags: Map<String, Tag>.of(appState.tagState.tags),
    );

    return updateSubstates(
      appState,
      [
        updateChartState((chartState) => chartState.copyWith(
              chartFilter: updatedFilter,
              filteredEntries: filteredEntries,
          rebuildChartData: true,
            )),
        updateFilterState((filterState) => FilterState.initial()),
      ],
    );
  }
}