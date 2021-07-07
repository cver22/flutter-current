import 'package:expenses/chart/chart_model/chart_state.dart';
import 'package:expenses/store/actions/chart_actions.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_dialog.dart';
import '../../env.dart';
import '../../utils/db_consts.dart';
import 'package:flutter/material.dart';

class ChartDialog extends StatefulWidget {
  const ChartDialog({Key? key}) : super(key: key);

  @override
  _ChartDialogState createState() => _ChartDialogState();
}

class _ChartDialogState extends State<ChartDialog> {
  late ChartType _chartType;
  late ChartDateGrouping _chartDateGrouping;
  late ChartDataGrouping _chartDataGrouping;
  late bool _showTrendLine;
  late bool _showMarkers;

  @override
  void initState() {
    ChartState chartState = Env.store.state.chartState;
    _chartType = chartState.chartType;
    _chartDateGrouping = chartState.chartDateGrouping;
    _chartDataGrouping = chartState.chartDataGrouping;
    _showTrendLine = chartState.showTrendLine;
    _showMarkers = chartState.showMarkers;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogWithActions(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Group by:'),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _chartDateGroupingRadio(chartDateGrouping: ChartDateGrouping.day, title: 'Day'),
              _chartDateGroupingRadio(chartDateGrouping: ChartDateGrouping.month, title: 'Month'),
              _chartDateGroupingRadio(chartDateGrouping: ChartDateGrouping.year, title: 'Year'),
            ],
          ),
          SizedBox(height: 32),
          Text('Chart Type:'),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _chartTypeRadio(chartType: ChartType.bar, title: 'Bar'),
              _chartTypeRadio(chartType: ChartType.line, title: 'Line'),
              _chartTypeRadio(chartType: ChartType.donut, title: 'Donut'),
            ],
          ),
          SizedBox(height: 32),
          Text('Show total of:'),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chartGroupingRadio(chartGrouping: ChartDataGrouping.total, title: 'Total'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _chartGroupingRadio(chartGrouping: ChartDataGrouping.categories, title: 'Categories'),
              _chartGroupingRadio(chartGrouping: ChartDataGrouping.subcategories, title: 'Subcategories'),
            ],
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Text('Show Trend Line'),
              SizedBox(width: 16),
              Switch(
                value: _showTrendLine,
                onChanged: (bool value) {
                  setState(() {
                    _showTrendLine = value;
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              Text('Show Markers'),
              SizedBox(width: 16),
              Switch(
                value: _showMarkers,
                onChanged: (bool value) {
                  setState(() {
                    _showMarkers = value;
                  });
                },
              ),
            ],
          )
        ],
      ),
      title: 'Chart Settings',
      actions: _actions(chartType: _chartType, chartGrouping: _chartDateGrouping),
    );
  }

  List<Widget> _actions({
    required ChartDateGrouping chartGrouping,
    required ChartType chartType,
  }) {
    return [
      TextButton(
        child: Text('Cancel'),
        onPressed: () {
          Get.back();
        },
      ),
      TextButton(
          child: Text('Save'),
          onPressed: () {
            Get.back();
            Env.store.dispatch(ChartSetOptions(
              chartType: _chartType,
              chartDataGrouping: _chartDataGrouping,
              chartDateGrouping: _chartDateGrouping,
              showTrendLine: _showTrendLine,
              showMarkers: _showMarkers,
            ));
            //TODO save new chart setting with Env
          }),
    ];
  }

  Widget _chartDateGroupingRadio({required ChartDateGrouping chartDateGrouping, required String title}) {
    return InkWell(
      onTap: () {
        setState(() {
          _chartDateGrouping = chartDateGrouping;
        });
      },
      child: Row(
        children: [
          _chartDateGrouping == chartDateGrouping
              ? Icon(Icons.radio_button_checked_outlined)
              : Icon(Icons.radio_button_off_outlined),
          SizedBox(width: 8),
          Text(title)
        ],
      ),
    );
  }

  Widget _chartTypeRadio({required ChartType chartType, required String title}) {
    return InkWell(
      onTap: () {
        setState(() {
          _chartType = chartType;
          if (_chartType == ChartType.bar) {
            _showMarkers = false;
          } else if (_chartType == ChartType.line) {
            _showMarkers = true;
          } else if (_chartType == ChartType.donut) {
            _showMarkers = false;
            if (_chartDataGrouping == ChartDataGrouping.total) {
              _chartDataGrouping = ChartDataGrouping.categories;
            }
          }
        });
      },
      child: Row(
        children: [
          _chartType == chartType ? Icon(Icons.radio_button_checked_outlined) : Icon(Icons.radio_button_off_outlined),
          SizedBox(width: 8),
          Text(title)
        ],
      ),
    );
  }

  Widget _chartGroupingRadio({required ChartDataGrouping chartGrouping, required String title}) {
    return InkWell(
      onTap: () {
        setState(() {
          _chartDataGrouping = chartGrouping;
        });
      },
      child: Row(
        children: [
          _chartDataGrouping == chartGrouping
              ? Icon(Icons.radio_button_checked_outlined)
              : Icon(Icons.radio_button_off_outlined),
          SizedBox(width: 8),
          Text(title)
        ],
      ),
    );
  }
}
