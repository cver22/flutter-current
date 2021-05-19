import 'package:expenses/utils/maybe.dart';
import 'package:flutter/material.dart';

import '../../env.dart';
import '../../filter/filter_model/filter.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../utils/db_consts.dart';
import 'app_button.dart';

class DateButton extends StatelessWidget {
  const DateButton({
    Key? key,
    this.initialDateTime,
    required this.onSave,
    this.label,
    required this.datePickerType,
  }) : super(key: key);

  final DateTime? initialDateTime;
  final Function(DateTime) onSave;
  final String? label;
  final DatePickerType datePickerType;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = initialDateTime ?? DateTime.now();
    DateTime newCombinedDateTime;
    bool pickTime = datePickerType == DatePickerType.entry;
    bool useShortDate = datePickerType == DatePickerType.start || datePickerType == DatePickerType.end;

    String display = initialDateTime == null
        ? label!
        : _getDateString(entryDate: dateTime, useShortDate: useShortDate, pickTime: pickTime);

    return AppButton(
      onPressed: () {
        Filter filter = Filter.initial();
        DateTime firstDate = DateTime(2001);
        DateTime lastDate = DateTime(2100);

        if (datePickerType != DatePickerType.entry) {
          filter = Env.store.state.filterState.filter.value;

          if (filter.startDate.isSome && datePickerType == DatePickerType.end) {
            firstDate = filter.startDate.value!.add(const Duration(days: 1));
            dateTime = firstDate;
          }

          if (filter.endDate.isSome && datePickerType == DatePickerType.start) {
            lastDate = filter.endDate.value!.subtract(const Duration(days: 1));
            dateTime = lastDate;
          }
        }

        showDatePicker(context: context, initialDate: dateTime, firstDate: firstDate, lastDate: lastDate)
            .then((newDate) {
          if (newDate != null && pickTime) {
            //called from entry
            Env.store.dispatch(EntryClearAllFocus());
            showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dateTime)).then((newTime) => {
                  if (newDate != null && newTime != null)
                    {
                      newCombinedDateTime = DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch.toInt() +
                          (((newTime.hour.toInt()) * 60) + newTime.minute.toInt()) * 60 * 1000),
                      onSave(newCombinedDateTime),
                    }
                });
          } else if (newDate != null && !pickTime) {
            newCombinedDateTime = DateTime.fromMillisecondsSinceEpoch(newDate.millisecondsSinceEpoch.toInt());
            onSave(newCombinedDateTime);
          }
        });
      },
      child: Text(display),
    );
  }
}

String _getDateString({required DateTime entryDate, required bool useShortDate, required bool pickTime}) {
  String time = '';
  if (pickTime) {
    String amPm = 'AM';
    int hour = entryDate.hour.toInt();
    if (hour > 12) {
      hour = hour - 12;
      amPm = 'PM';
    } else if(hour == 0) {
      hour = 12;
      amPm = 'Am';
    } else {
      hour = 12;
      amPm = 'PM';
    }
    time = '$hour:${entryDate.minute.toString().padLeft(2, '0')} $amPm';
  }

  List<String> monthNames = useShortDate ? MONTHS_SHORT : MONTHS_LONG;

  return '${monthNames[entryDate.month - 1]} ${entryDate.day.toString()}, ${entryDate.year.toString()} $time';
}
