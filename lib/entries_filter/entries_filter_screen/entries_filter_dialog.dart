import 'package:expenses/app/common_widgets/app_button.dart';
import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/app/common_widgets/date_button.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/master_category_list_dialog.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter_state.dart';
import 'package:expenses/store/actions/entries_filter_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:expenses/utils/currency.dart';

import '../../env.dart';

class EntriesFilterDialog extends StatefulWidget {
  @override
  _EntriesFilterDialogState createState() => _EntriesFilterDialogState();
}

class _EntriesFilterDialogState extends State<EntriesFilterDialog> {
  TextEditingController _minAmountController;
  TextEditingController _maxAmountController;
  FocusNode _minFocusNode;
  FocusNode _maxFocusNode;
  EntriesFilter filter;

  @override
  void initState() {
    _minAmountController = TextEditingController();
    _maxAmountController = TextEditingController();
    _minFocusNode = FocusNode();
    _minFocusNode.addListener(() {
      setState(() {});
    });
    _maxFocusNode = FocusNode();
    _maxFocusNode.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState<EntriesFilterState>(
        where: notIdentical,
        map: (state) => state.entriesFilterState,
        builder: (state) {
          filter = state.entriesFilter.value;
          return AppDialog(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.chevron_left),
                    //if no back action is passed, automatically set to pop context
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    'Entries Filter',
                    //TODO this should change based on entries/chart
                    style: TextStyle(fontSize: 20.0),
                  ),
                  Container(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _amountFilter(),
                      SizedBox(height: 16.0),
                      _dateFilter(),
                      SizedBox(height: 16.0),
                      _categoryFilter(),
                      SizedBox(height: 16.0),
                      _paidSpentFilter(),
                    ],
                  ),
                ),
              ),
            ],
          ));
        });
  }

  Widget _amountFilter() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Amount'),
        SizedBox(width: 20.0),
        Text('\$ '),
        Container(
          width: 100.0,
          child: _minMaxTextField(label: 'Min', controller: _minAmountController, focusNode: _minFocusNode),
        ),
        SizedBox(width: 10.0),
        Text('\$ '),
        Container(
          width: 100.0,
          child: _minMaxTextField(label: 'Max', controller: _maxAmountController, focusNode: _maxFocusNode),
        )
      ],
    );
  }

  TextField _minMaxTextField(
      {@required TextEditingController controller, @required String label, @required FocusNode focusNode}) {
    return TextField(
      style: TextStyle(color: Colors.black),
      controller: controller,
      focusNode: focusNode,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\-?\d*\.?\d{0,2}"))],
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        hintText: focusNode.hasFocus ? '' : label,
        hintStyle: TextStyle(color: ACTIVE_HINT_COLOR),
      ),
      onChanged: (newValue) {
        int intValue = parseNewValue(newValue: newValue);

        //TODO need to pass min and max Function(int) callback
        //Env.store.dispatch();
      },
    );
  }

  //TODO this may not work, i may need to redo this  or entry to handle maybes
  Widget _dateFilter() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DateButton(
          initialDateTime: filter.startDate.isSome ? filter.startDate.value : null,
          useShortDate: true,
          label: 'Start Date',
          pickTime: false,
          onSave: (dateTime) {
            Env.store.dispatch(FilterSetStartDate(dateTime: dateTime));
          },
        ),
        SizedBox(width: 8.0),
        Text('to'),
        SizedBox(width: 8.0),
        DateButton(
          initialDateTime: filter.endDate.isSome ? filter.endDate.value : null,
          useShortDate: true,
          label: 'End Date',
          pickTime: false,
          onSave: (dateTime) {
            Env.store.dispatch(FilterSetEndDate(dateTime: dateTime));
          },
        )
      ],
    );
  }

  Widget _categoryFilter() {
    return CategoryButton(
      label: 'Select Filter Categories',
      onPressed: () => {
        showDialog(
          context: context,
          builder: (_) => MasterCategoryListDialog(
            setLogFilter: SettingsLogFilter.filter,
          ),
        ),
      },
    );
  }

  //TODO
  Widget _paidSpentFilter() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(onPressed: null, child: null),
        SizedBox(width: 8.0),
        AppButton(onPressed: null, child: null),
      ],
    );
  }
}
