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
                trendlines: <Trendline>[
                  Trendline(isVisible: showTrendLine, type: TrendlineType.polynomial, color: Colors.blue)
                ],
                markerSettings: MarkerSettings(isVisible: showMarkers),
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
          } else if (chartState.chartType == ChartType.line && !loading) {
            series = <ChartSeries>[];
            for (int i = 0; i < categories.length; i++) {
              series.add(LineSeries<ChartData, DateTime>(
                trendlines: <Trendline>[
                  Trendline(isVisible: showTrendLine, type: TrendlineType.polynomial, color: Colors.blue)
                ],
                markerSettings: MarkerSettings(isVisible: showMarkers),
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
          } else if (chartState.chartType == ChartType.donut && !loading) {
            donutChartData.forEach((element) {
              total = total + element.amount;
            });

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
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
                ]),
                Expanded(
                  child: SfCircularChart(
                    title: ChartTitle(
                      text:
                          'Total spend: ${formattedAmount(currency: CurrencyService().findByCode('USD')!, value: total, showSymbol: true)}',
                    ),
                    legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      position: LegendPosition.bottom,
                      toggleSeriesVisibility: true,
                    ),
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
