import 'package:flutter/material.dart';

import '../../app/common_widgets/app_button.dart';
import '../../env.dart';
import '../../store/actions/logs_actions.dart';
import '../log_model/log.dart';

class LogNameForm extends StatefulWidget {
  final Log log;

  const LogNameForm({Key key, @required this.log}) : super(key: key);

  @override
  _LogNameFormState createState() => _LogNameFormState();
}

class _LogNameFormState extends State<LogNameForm> {
  Log log;
  bool editName = false;

  @override
  Widget build(BuildContext context) {
    log = widget.log;

    if (log.uid != null && !editName) {
      return AppButton(
          onPressed: () {
            setState(() {
              editName = true;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(log.name),
              SizedBox(width: 16.0),
              Icon(Icons.edit_outlined),
            ],
          ));
    } else {
      return TextFormField(
          decoration: InputDecoration(labelText: 'Log Title'),
          initialValue: log.name,
          autofocus: true,
          onChanged: (name) {
            Env.store.dispatch(LogUpdateName(name: name));
          }
          //TODO validate name cannot be empty
          //TODO need controllers
          );
    }
  }
}
