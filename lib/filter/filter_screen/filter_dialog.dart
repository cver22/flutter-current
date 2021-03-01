import 'package:expenses/app/common_widgets/app_button.dart';
import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/app/common_widgets/date_button.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/master_category_list_dialog.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/filter/filter_screen/filter_member_dialog.dart';
import 'package:expenses/store/actions/entries_actions.dart';
import 'package:expenses/store/actions/filter_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expenses/utils/currency.dart';
import 'package:get/get.dart';

import '../../env.dart';

class FilterDialog extends StatefulWidget {
  final EntriesCharts entriesChart;

  const FilterDialog({Key key, @required this.entriesChart}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  TextEditingController _minAmountController;
  TextEditingController _maxAmountController;
  FocusNode _minFocusNode;
  FocusNode _maxFocusNode;
  Filter filter;

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
    EntriesCharts entriesChart = widget.entriesChart;
    return ConnectState<FilterState>(
        where: notIdentical,
        map: (state) => state.filterState,
        builder: (filterState) {
          filter = filterState.filter.value;

          return AppDialogWithActions(
            title: 'Entries Filter',
            actions: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => Get.back(),
                ),
                FlatButton(
                  child: Text('Reset'),
                  onPressed: () => Env.store.dispatch(FilterSetReset()),
                ),
                FlatButton(
                    child: Text('Save Filter'),
                    onPressed: () {
                      if (entriesChart == EntriesCharts.entries) {
                        Env.store.dispatch(EntriesSetEntriesFilter());
                      } else if (entriesChart == EntriesCharts.charts) {
                        Env.store.dispatch(EntriesSetChartFilter());
                      }
                      Get.back();
                    }),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _amountFilter(filter: filter),
                    SizedBox(height: 16.0),
                    _dateFilter(),
                    SizedBox(height: 16.0),
                    _categoryFilter(),
                    SizedBox(height: 16.0),
                    _paidSpentFilter(filterState: filterState),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _amountFilter({Filter filter}) {
    bool minExceedMax = false;
    if (filter.minAmount.isSome && filter.maxAmount.isSome) {
      minExceedMax = filter.minAmount.value > filter.maxAmount.value;
    }
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Amount'),
        SizedBox(width: 20.0),
        Text('\$ '),
        Container(
          width: 100.0,
          child: _minMaxTextField(
            minExceedMax: minExceedMax,
            label: 'Min',
            controller: _minAmountController,
            focusNode: _minFocusNode,
            onChange: (minAmount) {
              Env.store.dispatch(FilterUpdateMinAmount(minAmount: minAmount));
            },
            textInputAction: TextInputAction.next,
          ),
        ),
        SizedBox(width: 10.0),
        Text('\$ '),
        Container(
          width: 100.0,
          child: _minMaxTextField(
            minExceedMax: minExceedMax,
            label: 'Max',
            controller: _maxAmountController,
            focusNode: _maxFocusNode,
            onChange: (maxAmount) {
              Env.store.dispatch(FilterUpdateMaxAmount(maxAmount: maxAmount));
            },
            textInputAction: TextInputAction.done,
          ),
        )
      ],
    );
  }

  TextField _minMaxTextField(
      {@required TextEditingController controller,
      @required String label,
      @required FocusNode focusNode,
      Function(int) onChange,
      TextInputAction textInputAction,
      bool minExceedMax}) {
    return TextField(
      style: TextStyle(color: minExceedMax ? Colors.red : Colors.black),
      controller: controller,
      focusNode: focusNode,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"^\-?\d*\.?\d{0,2}"))],
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        hintText: focusNode.hasFocus ? '' : label,
        hintStyle: TextStyle(color: ACTIVE_HINT_COLOR),
      ),
      onChanged: (newValue) {
        int intValue = parseNewValue(newValue: newValue);
        onChange(intValue);
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

  //TODO make app button show list of who paid
  Widget _paidSpentFilter({@required FilterState filterState}) {
    String membersPaidName = '';
    String membersSpentName = '';

    //build paid button String
    filterState.filter.value.membersPaid.forEach((memberId) {
      if (membersPaidName.length > 0) {
        membersPaidName += filterState.allMembers[memberId];
      } else {
        membersPaidName += '\, ${filterState.allMembers[memberId]}';
      }
    });

    //build spent button string
    filterState.filter.value.membersSpent.forEach((memberId) {
      if (membersSpentName.length > 0) {
        membersSpentName += filterState.allMembers[memberId];
      } else {
        membersSpentName += '\, ${filterState.allMembers[memberId]}';
      }
    });

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
            onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (_) => FilterMemberDialog(paidOrSpent: PaidOrSpent.paid),
                  ),
                },
            child: null),
        SizedBox(width: 8.0),
        AppButton(
            onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (_) => FilterMemberDialog(paidOrSpent: PaidOrSpent.paid),
                  ),
                },
            child: null),
      ],
    );
  }
}
