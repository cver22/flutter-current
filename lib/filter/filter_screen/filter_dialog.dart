import 'package:expenses/app/common_widgets/app_button.dart';
import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/app/common_widgets/date_button.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/master_category_list_dialog.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/filter/filter_screen/filter_log_dialog.dart';
import 'package:expenses/filter/filter_screen/filter_member_dialog.dart';
import 'package:expenses/filter/filter_screen/filter_tag_dialog.dart';
import 'package:expenses/log/log_model/log.dart';
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
            title: 'Filter',
            actions: _actions(entriesChart: entriesChart, save: filterState.updated),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _amountFilter(filter: filter),
                SizedBox(height: 8.0),
                _dateFilter(),
                SizedBox(height: 8.0),
                _categoryFilter(filterState: filterState),
                SizedBox(height: 8.0),
                _paidSpentFilter(filterState: filterState),
                SizedBox(height: 8.0),
                _logFilter(filterState: filterState),
                SizedBox(height: 8.0),
                _tagFilter(filterState: filterState),
              ],
            ),
          );
        });
  }

  Widget _actions({@required EntriesCharts entriesChart, @required bool save}) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FlatButton(
          child: Text('Cancel'),
          onPressed: () => Get.back(),
        ),
        FlatButton(
          child: Text('Clear'),
          onPressed: () {
            _minAmountController.clear();
            _maxAmountController.clear();
            Env.store.dispatch(FilterSetReset());
          },
        ),
        FlatButton(
            child: Text(save ? 'Save Filter' : 'Done'),
            onPressed: () {
              if (entriesChart == EntriesCharts.entries) {
                Env.store.dispatch(EntriesSetEntriesFilter());
              } else if (entriesChart == EntriesCharts.charts) {
                Env.store.dispatch(EntriesSetChartFilter());
              }
              Get.back();
            }),
      ],
    );
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

  Widget _categoryFilter({@required FilterState filterState}) {
    String categories = '';

    filterState.filter.value.selectedCategories.forEach((categoryName) {
      if (categories.length > 0) {
        categories += ', $categoryName';
      } else {
        categories += categoryName;
      }
    });

    return CategoryButton(
      label: categories.length > 0 ? categories : 'Select Filter Categories',
      filter: true,
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

  Widget _paidSpentFilter({@required FilterState filterState}) {
    String membersPaidString = '';
    String membersSpentString = '';

    //build paid button String
    filterState.filter.value.membersPaid.forEach((memberId) {
      if (membersPaidString.length > 0) {
        membersPaidString += '\, ${filterState.allMembers[memberId]}';
      } else {
        membersPaidString += filterState.allMembers[memberId];
      }
    });

    //build spent button string
    filterState.filter.value.membersSpent.forEach((memberId) {
      if (membersSpentString.length > 0) {
        membersSpentString += '\, ${filterState.allMembers[memberId]}';
      } else {
        membersSpentString += filterState.allMembers[memberId];
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
            child: Text(membersPaidString.length > 0 ? membersPaidString : 'Who paid?')),
        SizedBox(width: 8.0),
        AppButton(
            onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (_) => FilterMemberDialog(paidOrSpent: PaidOrSpent.spent),
                  ),
                },
            child: Text(membersSpentString.length > 0 ? membersSpentString : 'Who spent?')),
      ],
    );
  }

  Widget _logFilter({@required FilterState filterState}) {
    if (Env.store.state.logsState.logs.length > 0) {
      String selectedLogString = '';
      Map<String, Log> logs = Env.store.state.logsState.logs;

      filterState.filter.value.selectedLogs.forEach((logId) {
        if (selectedLogString.length > 0) {
          selectedLogString += '\, ${logs[logId].name}';
        } else {
          selectedLogString += logs[logId].name;
        }
      });

      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppButton(
            child: Text(selectedLogString.length > 0 ? selectedLogString : 'Select Logs'),
            onPressed: () => {
              showDialog(
                context: context,
                builder: (_) => FilterLogDialog(),
              ),
            },
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _tagFilter({FilterState filterState}) {
    List<String> selectedTags = filterState.filter.value.selectedTags;
    String tagString = '';
    if (selectedTags.isNotEmpty) {
      filterState.filter.value.selectedTags.forEach((tagName) {
        if (tagString.length > 0) {
          tagString += '\, #$tagName';
        } else {
          tagString += '#$tagName';
        }
      });
    } else {
      tagString = '#Tags';
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          child: Text(tagString),
          onPressed: () => {
            showDialog(
              context: context,
              builder: (_) => FilterTagDialog(),
            ),
          },
        ),
      ],
    );
  }
}
