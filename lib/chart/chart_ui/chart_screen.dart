import 'package:expenses/chart/chart_model/chart_data.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import '../../log/log_model/log.dart';
import '../../utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../chart/chart_model/expense_by_category.dart';
import '../../store/actions/chart_actions.dart';
import '../../env.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  _ChartScreenState createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    Env.store.dispatch(ChartUpdateData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ChartData> chartData = Env.store.state.chartState.chartData;
    List<ChartSeries> series = <ChartSeries>[];
    List<String> periods = Env.store.state.chartState.chartPeriods;

    for (int i = 0; i < periods.length; i++) {
      chartData.forEach((element) {
        series.add(StackedColumnSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData exp, _) => periods[i],
          yValueMapper: (ChartData exp, _) => element.amounts[i],
          name: element.categoryName,
        ));
      });
    }

    return SfCartesianChart(
      legend: Legend(isVisible: true),
      primaryXAxis: CategoryAxis(),
      series: series,
    );
  }
}
