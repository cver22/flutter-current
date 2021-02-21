import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/master_category_list_dialog.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter_state.dart';
import 'package:expenses/entry/entry_screen/entry_date_button.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                      SizedBox(
                        height: 16.0,
                      ),
                      _dateFilter(),
                      SizedBox(
                        height: 16.0,
                      ),
                      _categoryFilter(),
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
        SizedBox(
          width: 20.0,
        ),
        Container(
          width: 100.0,
          child: TextField(
            style: TextStyle(color: Colors.black),
            controller: _minAmountController,
            focusNode: _minFocusNode,
            decoration: InputDecoration(
              labelText: 'Min',
              hintText: _minFocusNode.hasFocus ? '' : 'Min',
              hintStyle: TextStyle(color: ACTIVE_HINT_COLOR),
            ),
          ),
        ),
        SizedBox(
          width: 20.0,
        ),
        Container(
          width: 100.0,
          child: TextField(
            style: TextStyle(color: Colors.black),
            controller: _maxAmountController,
            focusNode: _maxFocusNode,
            decoration: InputDecoration(
              labelText: 'Max',
              hintText: _maxFocusNode.hasFocus ? '' : 'Max',
              hintStyle: TextStyle(color: ACTIVE_HINT_COLOR),
            ),
          ),
        )
      ],
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
        ),
        SizedBox(
          width: 8.0,
        ),
        Text('to'),
        SizedBox(
          width: 8.0,
        ),
        DateButton(
          initialDateTime: filter.endDate.isSome ? filter.endDate.value : null,
          useShortDate: true,
          label: 'End Date',
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
}
