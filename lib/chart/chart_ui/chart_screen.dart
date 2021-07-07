import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/chart/chart_model/donut_chart_data.dart';
import 'package:expenses/currency/currency_utils/currency_formatters.dart';

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
    Legend _legend = Legend(
      isVisible: true,
      overflowMode: LegendItemOverflowMode.wrap,
      position: LegendPosition.bottom,
      toggleSeriesVisibility: true,
    );
    late DateTimeCategoryAxis _dateTimeCategoryAxis;
    late NumericAxis _numericAxis;
    late Trendline _trendLine;

    List<ChartData> chartData = <ChartData>[];
    List<DonutChartData> donutChartData = <DonutChartData>[];
    List<ChartSeries> series = <ChartSeries>[];
    List<String> categories = <String>[];
    int total = 0;

    return ConnectState<ChartState>(
        where: notIdentical,
        map: (state) => state.chartState,
        builder: (chartState) {
          bool loading = chartState.loading;
          bool showTrendLine = chartState.showTrendLine;
          bool showMarkers = chartState.showMarkers;
          total = 0;
          _numericAxis = NumericAxis(numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2));
          _trendLine = Trendline(
            isVisible: showTrendLine,
            type: TrendlineType.movingAverage,
            color: Colors.blue,
            isVisibleInLegend: false,
          );

          if (chartState.rebuildChartData) {
            loading = true;
          }
          categories = chartState.categories;
          chartData = chartState.chartData.values.toList();
          donutChartData = chartState.donutChartData;

          /* print('type: ${chartState.chartType}, '
              'date: ${chartState.chartDateGrouping}, '
              'categories: $categories');*/

          //sets date interval
          DateTimeIntervalType dateTimeIntervalType = DateTimeIntervalType.months;
          DateFormat dateFormat = DateFormat.MMM();
          _dateTimeCategoryAxis = DateTimeCategoryAxis(intervalType: dateTimeIntervalType, dateFormat: dateFormat);
          if (chartState.chartDateGrouping == ChartDateGrouping.year) {
            dateTimeIntervalType = DateTimeIntervalType.years;
            dateFormat = DateFormat.y();
          } else if (chartState.chartDateGrouping == ChartDateGrouping.day) {
            dateTimeIntervalType = DateTimeIntervalType.days;
            dateFormat = DateFormat.d();
          }

          if (chartState.chartType == ChartType.bar && !loading) {
            series = <ChartSeries>[];
            for (int i = 0; i < categories.length; i++) {
              series.add(StackedColumnSeries<ChartData, DateTime>(
                trendlines: <Trendline>[_trendLine],
                markerSettings: MarkerSettings(isVisible: showMarkers),
                dataSource: chartData,
                xValueMapper: (ChartData exp, _) => exp.dateTime,
                yValueMapper: (ChartData exp, _) => exp.amounts[i].toDouble() / 100,
                name: categories[i],
              ));
            }
            return SfCartesianChart(
              legend: _legend,
              primaryXAxis: _dateTimeCategoryAxis,
              primaryYAxis: _numericAxis,
              series: series,
              tooltipBehavior: _tooltipBehavior,
              zoomPanBehavior: _zoomPanBehavior,
            );
          } else if (chartState.chartType == ChartType.line && !loading) {
            series = <ChartSeries>[];
            for (int i = 0; i < categories.length; i++) {
              series.add(LineSeries<ChartData, DateTime>(
                trendlines: <Trendline>[_trendLine],
                markerSettings: MarkerSettings(isVisible: showMarkers),
                dataSource: chartData,
                xValueMapper: (ChartData exp, _) => exp.dateTime,
                yValueMapper: (ChartData exp, _) => exp.amounts[i].toDouble() / 100,
                name: categories[i],
              ));
            }
            return SfCartesianChart(
              legend: _legend,
              primaryXAxis: _dateTimeCategoryAxis,
              primaryYAxis: _numericAxis,
              series: series,
              tooltipBehavior: _tooltipBehavior,
              zoomPanBehavior: _zoomPanBehavior,
            );
          } else if (chartState.chartType == ChartType.donut && !loading) {
            donutChartData.forEach((element) {
              total = total + element.amount;
            });

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildDateSelector(chartState: chartState),
                Expanded(
                  child: SfCircularChart(
                    title: ChartTitle(
                      text:
                          'Total spend: ${formattedAmount(currency: CurrencyService().findByCode('USD')!, value: total, showSymbol: true)}',
                    ),
                    legend: _legend,
                    tooltipBehavior: _tooltipBehavior,
                    series: <CircularSeries>[
                      DoughnutSeries<DonutChartData, String>(
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        dataSource: donutChartData,
                        xValueMapper: (DonutChartData data, _) => data.category,
                        yValueMapper: (DonutChartData data, _) => data.amount.toDouble() / 100,
                        dataLabelMapper: (DonutChartData data, _) => data.text,
                        animationDuration: 600,
                      ),
                    ],
                  ),
                )
              ],
            );
          } else {
            //TODO can this run in an isolate?
            Env.store.dispatch(ChartUpdateData(rebuildChartData: true));
            return ModalLoadingIndicator(
              activate: true,
              loadingMessage: 'Loading Chart',
            );
          }
        });
  }

  Widget _buildDateSelector({required ChartState chartState}) {
    return Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(
          icon: Icon(Icons.chevron_left_outlined),
          onPressed: () {
            Env.store.dispatch(ChartIncrementDecrementDonutDate(increment: false));
          }),
      _getDonutDate(donutStartDate: chartState.donutStartDate, dateGrouping: chartState.chartDateGrouping),
      IconButton(
          icon: Icon(Icons.chevron_right_outlined),
          onPressed: () {
            Env.store.dispatch(ChartIncrementDecrementDonutDate(increment: true));
          }),
    ]);
  }

  Widget _getDonutDate({required DateTime donutStartDate, required ChartDateGrouping dateGrouping}) {
    String date = '';

    if (dateGrouping == ChartDateGrouping.day) {
      date = '${MONTHS_SHORT[donutStartDate.month - 1]} ${donutStartDate.day.toString()}, ${donutStartDate.year}';
    } else if (dateGrouping == ChartDateGrouping.month) {
      date = '${MONTHS_SHORT[donutStartDate.month - 1]} ${donutStartDate.year}';
    } else {
      date = '${donutStartDate.year}';
    }

    return Text(date);
  }
}
