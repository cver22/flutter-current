import 'package:expenses/chart/chart_model/chart_data.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../store/actions/chart_actions.dart';
import '../../env.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    _tooltipBehavior = TooltipBehavior(enable: true);
    Env.store.dispatch(ChartUpdateData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ChartData> chartData = Env.store.state.chartState.chartData;
    List<ChartSeries> series = <ChartSeries>[];
    List<String> categories = Env.store.state.chartState.categories;

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
      primaryXAxis: DateTimeCategoryAxis(
        intervalType: DateTimeIntervalType.months,
          dateFormat: DateFormat.MMM()
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
      ),
      series: series,
      tooltipBehavior: _tooltipBehavior,
        zoomPanBehavior: _zoomPanBehavior,
    );
  }
}
