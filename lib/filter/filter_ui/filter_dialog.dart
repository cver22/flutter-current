import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/app/common_widgets/list_tile_components.dart';
import 'package:expenses/store/actions/chart_actions.dart';
import '../../currency/currency_ui/app_currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_button.dart';
import '../../app/common_widgets/app_dialog.dart';
import '../../app/common_widgets/date_button.dart';
import '../../categories/categories_ui/category_button.dart';
import '../../categories/categories_ui/master_category_list_dialog.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../store/actions/entries_actions.dart';
import '../../store/actions/filter_actions.dart';
import '../../store/connect_state.dart';
import '../../currency/currency_utils/currency_formatters.dart';
import '../../utils/db_consts.dart';
import '../../utils/utils.dart';
import '../filter_model/filter.dart';
import '../filter_model/filter_state.dart';
import 'filter_log_dialog.dart';
import 'filter_member_dialog.dart';
import 'filter_tag_dialog.dart';

class FilterDialog extends StatefulWidget {
  final EntriesCharts entriesChart;

  const FilterDialog({Key? key, required this.entriesChart}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;
  late FocusNode _minFocusNode;
  late FocusNode _maxFocusNode;
  late Filter filter;

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

    //TODO change both of these to search based on settings default
    if (Env.store.state.filterState.filter.value.minAmount.isSome) {
      _minAmountController.value = TextEditingValue(
          text: formattedAmount(
              value: Env.store.state.filterState.filter.value.minAmount.value ?? 0,
              currency: CurrencyService().findByCode('CAD')!));
    }

    if (Env.store.state.filterState.filter.value.maxAmount.isSome) {
      _maxAmountController.value = TextEditingValue(
          text: formattedAmount(
              value: Env.store.state.filterState.filter.value.maxAmount.value ?? 0,
              currency: CurrencyService().findByCode('CAD')!));
    }

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
          if (filterState.filter.isSome) {
            filter = filterState.filter.value;

            return AppDialogWithActions(
              title: 'Filter',
              actions: _actions(filterState: filterState, entriesChart: entriesChart),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _amountFilter(filter: filter),
                    SizedBox(height: 16.0),
                    AppDivider(),
                    _quickDate(
                      showClear: filter.startDate.isSome || filter.endDate.isSome,
                      filterQuickDate: filter.quickDate,
                    ),
                    SizedBox(height: 8.0),
                    _dateFilter(),
                    SizedBox(height: 8.0),
                    AppDivider(),
                    SizedBox(height: 8.0),
                    _currency(filterState: filterState),
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
              ),
            );
          } else {
            return Container();
          }
        });
  }

  List<Widget> _actions({required FilterState filterState, required EntriesCharts entriesChart}) {
    String copySelection = entriesChart == EntriesCharts.entries ? 'Chart' : 'Entries';
    Filter? filter;
    if (entriesChart == EntriesCharts.entries && Env.store.state.chartState.chartFilter.isSome) {
      filter = Env.store.state.chartState.chartFilter.value;
    } else if (entriesChart == EntriesCharts.charts && Env.store.state.entriesState.entriesFilter.isSome) {
      filter = Env.store.state.entriesState.entriesFilter.value;
    }

    return [
      TextButton(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Copy'),
            Text('$copySelection Filter'),
          ],
        ),
        onPressed: filter != null
            ? () {
                Env.store.dispatch(FilterCopy(filter: filter!));
              }
            : null,
      ),
      TextButton(
        child: Text('Cancel'),
        onPressed: () => Get.back(),
      ),
      TextButton(
        child: Text('Clear'),
        onPressed: () {
          _minAmountController.clear();
          _maxAmountController.clear();
          Env.store.dispatch(FilterSetReset());
        },
      ),
      TextButton(
          child: Text(filterState.updated ? 'Save Filter' : 'Done'),
          onPressed: _minExceedMax(filter: filterState.filter.value)
              ? null
              : () {
                  if (entriesChart == EntriesCharts.entries) {
                    Env.store.dispatch(EntriesSetEntriesFilter());
                  } else if (entriesChart == EntriesCharts.charts) {
                    Env.store.dispatch(ChartSetChartFilter());
                  }
                  Get.back();
                }),
    ];
  }

  bool _minExceedMax({required Filter filter}) {
    bool canSave = false;
    if (filter.minAmount.isSome && filter.maxAmount.isSome && filter.minAmount.value! >= filter.maxAmount.value!) {
      canSave = true;
    }
    return canSave;
  }

  Widget _amountFilter({required Filter filter}) {
    bool minExceedMax = _minExceedMax(filter: filter);
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Amount'),
        SizedBox(width: 20.0),
        Text('\$ '),
        Expanded(
          flex: 1,
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
        Expanded(
          flex: 1,
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
      {required TextEditingController controller,
      required String label,
      required FocusNode focusNode,
      required Function(int) onChange,
      required TextInputAction textInputAction,
      required bool minExceedMax}) {
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
        int intValue = parseNewValue(
            newValue: newValue,
            currency: CurrencyService().findByCode('CAD')!); //TODO need this to work based on settings
        onChange(intValue);
      },
    );
  }

  Widget _dateFilter() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DateButton(
          //TODO add remove focus action to these buttons
          initialDateTime: filter.startDate.isSome ? filter.startDate.value : null,

          label: 'Start Date',
          datePickerType: DatePickerType.start,
          onSave: (dateTime) {
            Env.store.dispatch(FilterSetStartDate(date: dateTime));
          },
        ),
        SizedBox(width: 8.0),
        Text('to'),
        SizedBox(width: 8.0),
        DateButton(
          initialDateTime: filter.endDate.isSome ? filter.endDate.value : null,
          label: 'End Date',
          datePickerType: DatePickerType.end,
          onSave: (dateTime) {
            Env.store.dispatch(FilterSetEndDate(date: dateTime));
          },
        ),
      ],
    );
  }

  Widget _categoryFilter({required FilterState filterState}) {
    String categories = '';

    filterState.filter.value.selectedCategories.forEach((categoryName) {
      if (categories.isNotEmpty) {
        categories += ', $categoryName';
      } else {
        categories += 'Categories: $categoryName';
      }
    });

    return CategoryButton(
      label: categories.length > 0 ? categories : 'Select Filter Categories',
      filter: true,
      onPressed: () => {
        _unFocus(),
        showDialog(
          context: context,
          builder: (_) => MasterCategoryListDialog(
            setLogFilter: SettingsLogFilterEntry.filter,
          ),
        ),
      },
    );
  }

  Widget _paidSpentFilter({required FilterState filterState}) {
    String membersPaidString = '';
    String membersSpentString = '';

    //build paid button String
    filterState.filter.value.membersPaid.forEach((memberId) {
      if (membersPaidString.length > 0) {
        membersPaidString += '\, ${filterState.allMembers[memberId]}';
      } else {
        membersPaidString += 'Paying: ${filterState.allMembers[memberId]}';
      }
    });

    //build spent button string
    filterState.filter.value.membersSpent.forEach((memberId) {
      if (membersSpentString.length > 0) {
        membersSpentString += '\, ${filterState.allMembers[memberId]}';
      } else {
        membersSpentString += 'Spending: ${filterState.allMembers[memberId]}';
      }
    });

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: AppButton(
              onPressed: () => {
                    _unFocus(),
                    showDialog(
                      context: context,
                      builder: (_) => FilterMemberDialog(paidOrSpent: PaidOrSpent.paid),
                    ),
                  },
              child: Text(
                membersPaidString.length > 0 ? membersPaidString : 'Who paid?',
                overflow: TextOverflow.visible,
                softWrap: true,
              )),
        ),
        SizedBox(width: 8.0),
        Expanded(
          flex: 1,
          child: AppButton(
              onPressed: () => {
                    _unFocus(),
                    showDialog(
                      context: context,
                      builder: (_) => FilterMemberDialog(paidOrSpent: PaidOrSpent.spent),
                    ),
                  },
              child: Text(
                membersSpentString.length > 0 ? membersSpentString : 'Who spent?',
                overflow: TextOverflow.visible,
                softWrap: true,
              )),
        ),
      ],
    );
  }

  Widget _logFilter({required FilterState filterState}) {
    if (Env.store.state.logsState.logs.isNotEmpty) {
      String selectedLogString = '';
      Map<String, Log> logs = Env.store.state.logsState.logs;

      filterState.filter.value.selectedLogs.forEach((logId) {
        if (selectedLogString.length > 0) {
          selectedLogString += '\, ${logs[logId]!.name}';
        } else {
          selectedLogString += 'Logs: ${logs[logId]!.name}';
        }
      });

      return AppButton(
        child: Text(selectedLogString.length > 0 ? selectedLogString : 'Select Logs'),
        onPressed: () => {
          _unFocus(),
          showDialog(
            context: context,
            builder: (_) => FilterLogDialog(),
          ),
        },
      );
    } else {
      return Container();
    }
  }

  Widget _tagFilter({required FilterState filterState}) {
    List<String?> selectedTags = filterState.filter.value.selectedTags;
    String tagString = '';
    if (selectedTags.isNotEmpty) {
      filterState.filter.value.selectedTags.forEach((tagName) {
        if (tagString.length > 0) {
          tagString += '\, #$tagName';
        } else {
          tagString += 'Tags: #$tagName';
        }
      });
    } else {
      tagString = '#Tags';
    }

    return AppButton(
      child: Text(tagString),
      onPressed: () => {
        _unFocus(),
        showDialog(
          context: context,
          builder: (_) => FilterTagDialog(),
        ),
      },
    );
  }

  void _unFocus() {
    _minFocusNode.unfocus();
    _maxFocusNode.unfocus();
  }

  Widget _currency({required FilterState filterState}) {
    return AppCurrencyPicker(
      title: 'Filter Currencies',
      withConversionRates: false,
      unFocus: () {
        _unFocus();
      },
      returnCurrency: (currency) {
        Env.store.dispatch(FilterSelectDeselectCurrency(currency: currency));
      },
      currencies: _getCurrencyList(usedCurrencyCodes: filterState.usedCurrencies),
      multiSelect: true,
      buttonLabel: _buildButtonLabel(),
    );
  }

  String _buildButtonLabel() {
    List<String> selectedCurrencies = Env.store.state.filterState.filter.value.selectedCurrencies;
    String buttonLabel = '';

    if (selectedCurrencies.isNotEmpty) {
      selectedCurrencies.forEach((currencyCode) {
        if (buttonLabel.length > 0) {
          buttonLabel += '\, ${currencyLabelFromCode(currencyCode: currencyCode)}';
        } else {
          buttonLabel += 'Currencies: ${currencyLabelFromCode(currencyCode: currencyCode)}';
        }
      });
    } else {
      buttonLabel = 'Select Currencies';
    }

    return buttonLabel;
  }

  List<Currency> _getCurrencyList({required List<String> usedCurrencyCodes}) {
    List<Currency> currencyList = <Currency>[];

    usedCurrencyCodes.forEach((code) {
      currencyList.add(CurrencyService().findByCode(code)!);
    });

    return currencyList;
  }

  Widget _quickDate({required QuickDate filterQuickDate, required bool showClear}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                child: Text(
                  'Clear Dates',
                  style: TextStyle(color: showClear ? Colors.red : Colors.grey),
                ),
                onPressed: showClear
                    ? () {
                        Env.store.dispatch(FilterClearDates());
                      }
                    : null),
            _quickDateRadio(
                filterQuickDate: filterQuickDate,
                radioQuickDate: QuickDate.thisMonth,
                title: MONTHS_SHORT[DateTime.now().month - 1]),
            _quickDateRadio(
                filterQuickDate: filterQuickDate,
                radioQuickDate: QuickDate.thisYear,
                title: DateTime.now().year.toString()),
          ],
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _quickDateRadio(filterQuickDate: filterQuickDate, radioQuickDate: QuickDate.hours24, title: '24 hours'),
            _quickDateRadio(filterQuickDate: filterQuickDate, radioQuickDate: QuickDate.days30, title: '30 days'),
            _quickDateRadio(filterQuickDate: filterQuickDate, radioQuickDate: QuickDate.months12, title: '12 months'),
          ],
        ),
      ],
    );
  }

  Widget _quickDateRadio({
    required QuickDate radioQuickDate,
    required String title,
    required QuickDate filterQuickDate,
  }) {
    late DateTime startDate;
    DateTime endDate = DateTime.now();
    if (radioQuickDate == QuickDate.hours24) {
      startDate = DateTime(endDate.year, endDate.month, endDate.day - 1);
    } else if (radioQuickDate == QuickDate.days30) {
      startDate = DateTime(endDate.year, endDate.month - 1, endDate.day);
    } else if (radioQuickDate == QuickDate.thisMonth) {
      startDate = DateTime(endDate.year, endDate.month, 1);
    } else if (radioQuickDate == QuickDate.thisYear) {
      startDate = DateTime(endDate.year, 1, 1);
    } else {
      startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
    }

    return InkWell(
      onTap: () {
        setState(() {
          Env.store.dispatch(FilterSetDates(
            startDate: startDate,
            endDate: endDate,
            quickDate: radioQuickDate,
          ));
        });
      },
      child: Row(
        children: [
          filterQuickDate == radioQuickDate
              ? Icon(Icons.radio_button_checked_outlined)
              : Icon(Icons.radio_button_off_outlined),
          SizedBox(width: 2),
          Text(title)
        ],
      ),
    );
  }
}
