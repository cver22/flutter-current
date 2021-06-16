import 'package:expenses/chart/chart_model/chart_data.dart';
import 'package:flutter/material.dart';

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
    Map<String, ChartData> chartMap = <String, ChartData>{};
    List<String> periods = <String>[];

    //TODO this will need to be refactored to handle named categories and other things that the filter handles

    entries.forEach((key, entry) {
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

          expense = ExpenseByCategory(
              dateTime: DateTime(entryYear, entryMonth, entryDay),
              category: entry.categoryId!,
              subcategory: entry.subcategoryId!,
              members: members,
              amount: amount);

          expenseByCategoryList.add(expense);
        }
        expenseByCategoryList.sort((a, b) => a.dateTime.compareTo(b.dateTime));


      }
    });

    //TODO this is UGLY!!!!
    expenseByCategoryList.forEach((exp) {
      String expDate = '${MONTHS_SHORT[exp.dateTime.month - 1]} ${exp.dateTime.year.toString()}';

      if (!periods.contains(expDate)) {
        periods.add(expDate);
      }
    });
    print('periods $periods');

    List<int> amounts = <int>[];

    periods.forEach((element) {
      amounts.add(0);
    });
    print('amounts $amounts');
    ChartData chartDataBase = ChartData(amounts: amounts);
    print(chartDataBase);

    expenseByCategoryList.forEach((exp) {
      ChartData newChartData = chartDataBase;
      String expDate = '${MONTHS_SHORT[exp.dateTime.month - 1]} ${exp.dateTime.year.toString()}';
      int dateIndex = periods.indexOf(expDate);
      int chartDataAmount = 0;

      if(chartMap.containsKey(exp.category)){
        ChartData chartData = chartMap[exp.category]!;
        List<int> chartDataAmounts = List<int>.from(chartData.amounts);
        print(chartDataAmounts);
        chartDataAmount = exp.amount + chartDataAmounts[dateIndex];
        chartDataAmounts.removeAt(dateIndex);
        chartDataAmounts.insert(dateIndex, chartDataAmount);
        chartData = chartData.copyWith(amounts: chartDataAmounts);
        chartMap.putIfAbsent(exp.category, () => chartData);
      } else {
        print('triggered');
        List<int> chartDataAmounts = List<int>.from(newChartData.amounts);
        print('chartDataAmounts: $chartDataAmounts');
        chartDataAmount = exp.amount;
        chartDataAmounts.removeAt(dateIndex);
        if(dateIndex > chartDataAmounts.length) {
          chartDataAmounts.add(chartDataAmount);
        } else {
          chartDataAmounts.insert(dateIndex, chartDataAmount);
        }
        print('chartDataAmounts: $chartDataAmounts');
        newChartData = newChartData.copyWith(amounts: chartDataAmounts);
        chartMap.putIfAbsent(exp.category, () => newChartData);
      }

    });

    return updateSubstates(
      appState,
      [
        _updateChartState((chartState) => chartState.copyWith(expenseByCategory: expenseByCategoryList,
        chartPeriods: periods, chartData: chartMap.values.toList())),
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
