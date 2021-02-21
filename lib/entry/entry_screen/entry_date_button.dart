import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class DateButton extends StatelessWidget {
  const DateButton({
    Key key,
    this.initialDateTime,
    this.onSave,
    this.useShortDate = false,
    this.label,
  }) : super(key: key);

  final DateTime initialDateTime;
  final Function(DateTime) onSave;
  final bool useShortDate;
  final String label;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = initialDateTime ?? DateTime.now();
    DateTime newCombinedDateTime;

    String display = label != null ? 'Select Date' : _getDateString(entryDate: dateTime, useShortDate: useShortDate);

    return RaisedButton(
      elevation: RAISED_BUTTON_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
      onPressed: () => showDatePicker(
              context: context, initialDate: dateTime, firstDate: DateTime(2001), lastDate: DateTime(2100))
          .then((newDate) => {
                if (newDate != null)
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
                  }
              }),
      child: Text(display),
    );
  }
}

String _getDateString({@required DateTime entryDate, @required bool useShortDate}) {
  String amPm = 'AM';
  int hour = entryDate?.hour?.toInt();
  if (hour >= 12) {
    hour = hour - 12;
    amPm = 'PM';
  }

  List<String> monthNames = useShortDate ? MONTHS_SHORT : MONTHS_LONG;

  return '${monthNames[entryDate.month - 1]} ${entryDate.day.toString()}, ${entryDate.year.toString()} $hour:${entryDate.minute.toString().padLeft(2, '0')} $amPm';
}
