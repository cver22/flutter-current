import '../../chart/chart_model/chart_data.dart';
import '../../log/log_model/log.dart';
import '../../utils/db_consts.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../chart/chart_model/chart_state.dart';
import '../../app/models/app_state.dart';
import 'app_actions.dart';

AppState Function(AppState) _updateChartState(ChartState update(chartState)) {
  return (state) => state.copyWith(chartState: update(state.chartState));
}

class ChartUpdateData implements AppAction {
  @override
  AppState updateState(AppState appState) {

    Map<String, AppEntry> entries = Map<String, AppEntry>.from(appState.entriesState.entries);
    ChartGrouping chartGrouping = appState.chartState.chartGrouping;
    Map<DateTime, ChartData> chartMap = <DateTime, ChartData>{};
    List<String> categoriesList = <String>[];
    Map<String, Log> logs = Map<String, Log>.from(appState.logsState.logs);
    Map<String, String> categoriesMap = <String, String>{};
    Map<String, String> subcategoriesMap = <String, String>{};

    logs.forEach((key, log) {
      log.categories.forEach((category) {
        if (!categoriesMap.containsKey(category.id) && category.id != TRANSFER_FUNDS) {
          categoriesMap.putIfAbsent(category.id!, () => category.name!);
        }
      });
      log.subcategories.forEach((subcategory) {
        if (!subcategoriesMap.containsKey(subcategory.id)) {
          subcategoriesMap.putIfAbsent(subcategory.id!, () => subcategory.name!);
        }
      });
    });

    //TODO this will need to be refactored to handle named categories and other things that the filter handles

    //list all categories
    entries.forEach((key, entry) {
      if (entry.categoryId != TRANSFER_FUNDS) {
        String category = categoriesMap[entry.categoryId!]!;
        if (!categoriesList.contains(category)) {
          categoriesList.add(category);
        }
      }
    });
    //TODO sort this to match the log category order
    categoriesList.sort();

    //chart data base to contain array of the same size at the number of categories
    List<int> amounts = <int>[];

    categoriesList.forEach((category) {
      amounts.add(0);
    });

    ChartData chartDataBase = ChartData(amounts: amounts);

    entries.forEach((key, entry) {
      if (entry.categoryId != TRANSFER_FUNDS) {
        DateTime expDateTime = DateTime(entry.dateTime.year);
        if (chartGrouping == ChartGrouping.day) {
          expDateTime = DateTime(entry.dateTime.year, entry.dateTime.month, entry.dateTime.day);
        } else if (chartGrouping == ChartGrouping.month) {
          expDateTime = DateTime(entry.dateTime.year, entry.dateTime.month);
        }

        int categoryIndex = categoriesList.indexOf(categoriesMap[entry.categoryId!]!);
        int chartDataAmount = 0;
        List<int> seriesAmounts = <int>[];
        ChartData chartData = chartDataBase;
        bool newSeries = true;

        if (chartMap.containsKey(expDateTime)) {
          chartData = chartMap[expDateTime]!;
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
          chartData = chartData.copyWith(amounts: seriesAmounts, dateTime: expDateTime);
        } else {
          chartData = chartData.copyWith(amounts: seriesAmounts);
        }
        chartMap.update(expDateTime, (v) => chartData, ifAbsent: () => chartData);
      }
    });


    return updateSubstates(
      appState,
      [
        _updateChartState((chartState) => chartState.copyWith(
            categories: categoriesList, chartData: chartMap.values.toList())),
      ],
    );
  }
}

class ChartSetGrouping implements AppAction {
  final ChartGrouping chartGrouping;

  ChartSetGrouping({required this.chartGrouping});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateChartState((chartState) => chartState.copyWith(chartGrouping: chartGrouping)),
      ],
    );
  }
}

class ChartSetType implements AppAction {
  final ChartType chartType;

  ChartSetType({required this.chartType});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateChartState((chartState) => chartState.copyWith(chartType: chartType)),
      ],
    );
  }
}
