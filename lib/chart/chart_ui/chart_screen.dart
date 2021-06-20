import '../../chart/chart_model/chart_data.dart';
import '../../chart/chart_model/chart_state.dart';
import '../../store/connect_state.dart';
import '../../utils/db_consts.dart';
import '../../utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../store/actions/chart_actions.dart';
import '../../env.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);
    ZoomPanBehavior _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    Env.store.dispatch(ChartUpdateData(rebuildChartData: true));
    List<ChartData> chartData = <ChartData>[];
    List<ChartSeries> series = <ChartSeries>[];
    List<String> categories = <String>[];

    return ConnectState<ChartState>(
        where: notIdentical,
        map: (state) => state.chartState,
        builder: (chartState) {
          categories = chartState.categories;
          chartData = chartState.chartData.values.toList();
          //sets date interval
          DateTimeIntervalType dateTimeIntervalType = DateTimeIntervalType.months;
          DateFormat dateFormat = DateFormat.MMM();
          if (chartState.chartDateGrouping == ChartDateGrouping.year) {
            dateTimeIntervalType = DateTimeIntervalType.years;
            dateFormat = DateFormat.y();
          } else if (chartState.chartDateGrouping == ChartDateGrouping.day) {
            dateTimeIntervalType = DateTimeIntervalType.days;
            dateFormat = DateFormat.d();
          }

          if (chartState.chartType == ChartType.bar) {
            series = <ChartSeries>[];
            for (int i = 0; i < categories.length; i++) {
              series.add(StackedColumnSeries<ChartData, DateTime>(
                dataSource: chartData,
                xValueMapper: (ChartData exp, _) => exp.dateTime,
                yValueMapper: (ChartData exp, _) => exp.amounts[i].toDouble() / 100,
                name: categories[i],
              ));
            }
            return SfCartesianChart(
              legend: Legend(isVisible: true),
              primaryXAxis: DateTimeCategoryAxis(intervalType: dateTimeIntervalType, dateFormat: dateFormat),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
              ),
              series: series,
              tooltipBehavior: _tooltipBehavior,
              zoomPanBehavior: _zoomPanBehavior,
            );
          } else if (chartState.chartType == ChartType.line) {
            series = <ChartSeries>[];
            for (int i = 0; i < categories.length; i++) {
              series.add(LineSeries<ChartData, DateTime>(
                dataSource: chartData,
                xValueMapper: (ChartData exp, _) => exp.dateTime,
                yValueMapper: (ChartData exp, _) => exp.amounts[i].toDouble() / 100,
                name: categories[i],
              ));
            }
            return SfCartesianChart(
              legend: Legend(isVisible: true),
              primaryXAxis: DateTimeCategoryAxis(intervalType: dateTimeIntervalType, dateFormat: dateFormat),
              primaryYAxis: NumericAxis(
                numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
              ),
              series: series,
              tooltipBehavior: _tooltipBehavior,
              zoomPanBehavior: _zoomPanBehavior,
            );
          } else {
            return Container();
            /* for (int i = 0; i < categories.length; i++) {
            series.add(DoughnutSeries<ChartData, DateTime>(
              dataSource: chartData,
              xValueMapper: (ChartData exp, _) => exp.dateTime,
              yValueMapper: (ChartData exp, _) => exp.amounts[i].toDouble() / 100,
              name: categories[i],
            ));
            }
            return SfCircularChart(
              series: series,
              tooltipBehavior: _tooltipBehavior,
            );*/

          }
        });
  }
}
