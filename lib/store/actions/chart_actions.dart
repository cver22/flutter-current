import 'package:expenses/chart/chart_model/chart_data.dart';
import 'package:expenses/log/log_model/log.dart';
import '../../member/member_model/member.dart';
import '../../utils/db_consts.dart';
import '../../chart/chart_model/expense_by_category.dart';
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
    List<ExpenseByCategory> expenseByCategoryList = <ExpenseByCategory>[];
    Map<String, AppEntry> entries = Map<String, AppEntry>.from(appState.entriesState.entries);
    ChartGrouping chartGrouping = appState.chartState.chartGrouping;
    Map<DateTime, ChartData> chartMap = <DateTime, ChartData>{};
    List<String> categories = <String>[];
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

    entries.forEach((key, entry) {
      if(entry.categoryId != TRANSFER_FUNDS) {
        int entryYear = entry.dateTime.year;
        int entryMonth = entry.dateTime.month;
        int entryDay = entry.dateTime.day;
        Map<String, Member> members = <String, Member>{};
        int amount = 0;

        if (chartGrouping == ChartGrouping.month) {
          ExpenseByCategory? expense;

          if (expenseByCategoryList.isNotEmpty) {
            int index = expenseByCategoryList.indexWhere(
                  (element) =>
              element.dateTime.year == entryYear &&
                  element.dateTime.month == entryMonth &&
                  element.category == entry.categoryId &&
                  element.subcategory == entry.subcategoryId,
            );
            if (index >= 0) {
              expense = expenseByCategoryList.removeAt(index);
            }
          }

          if (expense != null) {
            members = expense.members;
            amount = expense.amount;

            entry.entryMembers.forEach((key, entryMember) {
              Member? member;
              if (members.containsKey(key)) {
                member = members[key];
                int paid = member!.paid! + (entryMember.paid ?? 0);
                int spent = member.spent! + (entryMember.spent ?? 0);
                amount += entryMember.paid ?? 0;
                member = member.copyWith(paid: paid, spent: spent);
                members.update(key, (value) => member!);
              } else {
                member = Member(uid: entryMember.uid, paid: entryMember.paid ?? 0, spent: entryMember.spent ?? 0);
                amount += entryMember.paid ?? 0;
                members.putIfAbsent(key, () => member!);
              }
            });
          } else {
            entry.entryMembers.forEach((key, entryMember) {
              Member member = Member(uid: entryMember.uid, paid: entryMember.paid ?? 0, spent: entryMember.spent ?? 0);
              amount += entryMember.paid ?? 0;
              members.putIfAbsent(key, () => member);
            });

            //TODO this won't handle multiple logs with identical named categories but different category id, will need to sue the chart method
            expense = ExpenseByCategory(
                dateTime: DateTime(entryYear, entryMonth, entryDay),
                category: categoriesMap[entry.categoryId!]!,
                subcategory: subcategoriesMap[entry.subcategoryId] ?? 'No Subcategory',
                members: members,
                amount: amount);

            expenseByCategoryList.add(expense);
          }
          expenseByCategoryList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        }
      }

    });

    //list all categories
    expenseByCategoryList.forEach((exp) {
      String category = exp.category;

      if (!categories.contains(category)) {
        categories.add(category);
      }
    });

    //chart data base to contain array of the same size at the number of categories
    List<int> amounts = <int>[];

    categories.forEach((category) {
      amounts.add(0);
    });
    print('amounts $amounts');
    ChartData chartDataBase = ChartData(amounts: amounts);

    expenseByCategoryList.forEach((exp) {
      DateTime expDateTime = DateTime(exp.dateTime.year, exp.dateTime.month);
      int categoryIndex = categories.indexOf(exp.category);
      int chartDataAmount = 0;
      List<int> seriesAmounts = <int>[];
      ChartData chartData = chartDataBase;
      bool newSeries = true;

      if (chartMap.containsKey(expDateTime)) {
        chartData = chartMap[expDateTime]!;
        seriesAmounts = List<int>.from(chartData.amounts);
        chartDataAmount = exp.amount + seriesAmounts[categoryIndex];
        seriesAmounts.removeAt(categoryIndex);
        newSeries = false;

        chartData = chartData.copyWith(amounts: seriesAmounts);
      } else {
        seriesAmounts = List<int>.from(chartDataBase.amounts);
        chartDataAmount = exp.amount;
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
    });

    print('chart map: $chartMap');

    return updateSubstates(
      appState,
      [
        _updateChartState((chartState) => chartState.copyWith(
            expenseByCategory: expenseByCategoryList, categories: categories, chartData: chartMap.values.toList())),
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
