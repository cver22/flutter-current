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
  late ChartGrouping _chartGrouping;

  @override
  void initState() {
    var _chartState = Env.store.state.chartState;
    _chartType = _chartState.chartType;
    _chartGrouping = _chartState.chartGrouping;

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
              _chartGroupingRadio(chartGrouping: ChartGrouping.day, title: 'Day'),
              _chartGroupingRadio(chartGrouping: ChartGrouping.month, title: 'Month'),
              _chartGroupingRadio(chartGrouping: ChartGrouping.year, title: 'Year'),
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
        ],
      ),
      title: 'Chart Settings',
      actions: _actions(chartType: _chartType, chartGrouping: _chartGrouping),
    );
  }

  List<Widget> _actions({
    required ChartGrouping chartGrouping,
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
            Env.store.dispatch(ChartSetOptions(
              chartGrouping: _chartGrouping,
              chartType: _chartType,
            ));
            //TODO save new chart setting with Env
            Get.back();
          }),
    ];
  }

  Widget _chartGroupingRadio({required ChartGrouping chartGrouping, required String title}) {
    return InkWell(
      onTap: () {
        setState(() {
          _chartGrouping = chartGrouping;
        });
      },
      child: Row(
        children: [
          _chartGrouping == chartGrouping
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
}
