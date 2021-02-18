import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class EntryDateButton extends StatelessWidget {
  const EntryDateButton({
    Key key,
    @required this.context,
    @required this.entry,
  }) : super(key: key);

  final BuildContext context;
  final MyEntry entry;

  @override
  Widget build(BuildContext context) {
    DateTime entryDate = entry?.dateTime;
    DateTime newCombinedDateTime;

    String date = _getDateString(entryDate: entryDate);

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
                              Env.store.dispatch(UpdateEntryDateTime(dateTime: newCombinedDateTime)),
                            }
                        })
                  }
              }),
      child: Text(date),
    );
  }
}

String _getDateString({DateTime entryDate}) {
  String amPm = 'AM';
  int hour = entryDate?.hour?.toInt();
  if (hour >= 12) {
    hour = hour - 12;
    amPm = 'PM';
  }

  return '${MONTHS_LONG[entryDate.month - 1]} ${entryDate.day.toString()}, ${entryDate.year.toString()} $hour:${entryDate.minute.toString().padLeft(2, '0')} $amPm';
}
