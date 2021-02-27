import 'package:expenses/app/common_widgets/app_button.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class DateButton extends StatelessWidget {
  const DateButton({
    Key key,
    this.initialDateTime,
    this.onSave,
    this.useShortDate = false,
    this.label,
    this.pickTime = true,
  }) : super(key: key);

  final DateTime initialDateTime;
  final Function(DateTime) onSave;
  final bool useShortDate;
  final String label;
  final bool pickTime;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = initialDateTime ?? DateTime.now();
    DateTime newCombinedDateTime;

    String display = initialDateTime == null ? label : _getDateString(entryDate: dateTime, useShortDate: useShortDate, pickTime: pickTime);

    return AppButton(
      onPressed: () => showDatePicker(
              context: context, initialDate: dateTime, firstDate: DateTime(2001), lastDate: DateTime(2100))
          .then((newDate) => {
                if (newDate != null && pickTime)
                  {
                    showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dateTime)).then((newTime) => {
                          if (newDate != null && newTime != null)
                            {
                              newCombinedDateTime = DateTime.fromMillisecondsSinceEpoch(
                                  newDate.millisecondsSinceEpoch.toInt() +
                                      (((newTime.hour.toInt()) * 60) + newTime.minute.toInt()) * 60 * 1000),
                              onSave(newCombinedDateTime),
                            }
                        })
                  } else {
                  newCombinedDateTime = DateTime.fromMillisecondsSinceEpoch(
                      newDate.millisecondsSinceEpoch.toInt()),
                  onSave(newCombinedDateTime),
                }
              }),
      child: Text(display),
    );
  }
}

String _getDateString({@required DateTime entryDate, @required bool useShortDate, @required bool pickTime}) {
  String time = '';
  if(pickTime){
    String amPm = 'AM';
    int hour = entryDate?.hour?.toInt();
    if (hour >= 12) {
      hour = hour - 12;
      amPm = 'PM';
    }
    time = '$hour:${entryDate.minute.toString().padLeft(2, '0')} $amPm';
  }

  List<String> monthNames = useShortDate ? MONTHS_SHORT : MONTHS_LONG;

  return '${monthNames[entryDate.month - 1]} ${entryDate.day.toString()}, ${entryDate.year.toString()} $time';
}
