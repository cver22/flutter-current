
import 'package:expenses/env.dart';
import 'package:flutter/material.dart';


class LogsScreen extends StatelessWidget {
  //TODO LogsBloc _logsBloc; and how to dispose

  @override
  Widget build(BuildContext context) {
    return Text(Env.store.state.authState.user.toString());
  }
}
