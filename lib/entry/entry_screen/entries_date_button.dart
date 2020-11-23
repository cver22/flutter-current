import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:flutter/material.dart';


class EntriesDateButton extends StatelessWidget {
  const EntriesDateButton({
    Key key,
    @required this.context,
    @required this.log,
    @required this.entry,
  }) : super(key: key);

  final BuildContext context;
  final Log log;
  final MyEntry entry;

  @override
  Widget build(BuildContext context) {
    DateTime entryDate = entry?.dateTime;
    List months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    String amPm = 'AM';
    int hour = entryDate?.hour?.toInt();
    if (hour >= 12) {
      hour = hour - 12;
      amPm = 'PM';
    }

    String date =
        '${months[entryDate.month - 1]} ${entryDate.day.toString()}, ${entryDate.year.toString()} $hour:${entryDate.minute.toString().padLeft(2, '0')} $amPm';

    DateTime newCombinedDateTime;

    return RaisedButton(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      onPressed: () => showDatePicker(
              context: context, initialDate: entryDate, firstDate: DateTime(2001), lastDate: DateTime(2100))
          .then((newDate) => {
                if (newDate != null)
                  {
                    showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(entryDate)).then((newTime) => {
                          if (newDate != null && newTime != null)
                            {
                              newCombinedDateTime = DateTime.fromMillisecondsSinceEpoch(
                                  newDate.millisecondsSinceEpoch.toInt() +
                                      (((newTime.hour.toInt()) * 60) + newTime.minute.toInt()) * 60 * 1000),
                              Env.store.dispatch(UpdateSelectedEntry(dateTime: newCombinedDateTime)),
                            }
                        })
                  }
              }),
      child: Text(date),
    );
  }
}
