import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';
import '../../store/actions/logs_actions.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../utils/expense_routes.dart';
import 'app_button.dart';

class EmptyContent extends StatelessWidget {
  const EmptyContent({
    Key key,
    this.title = 'Nothing here',
    this.message = 'Add a new item to get started',
    this.child,
  }) : super(key: key);
  final String title;
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 32.0, color: Colors.black54),
          ),
          Text(
            message,
            style: TextStyle(fontSize: 16.0, color: Colors.black54),
          ),
          child == null
              ? Container()
              : SizedBox(
                  height: 20.0,
                ),
          child ?? Container(),
        ],
      ),
    );
  }
}

class LogEmptyContent extends StatelessWidget {
  const LogEmptyContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyContent(
      message: 'You don\'t have any logs yet.',
      child: AppButton(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Add a Log',
            style: TextStyle(fontSize: 30.0),
          ),
        ),
        onPressed: () {
          Env.store.dispatch(SetNewLog());
          Get.toNamed(ExpenseRoutes.addEditLog);
        },
      ),
    );
  }
}

class EntriesEmptyContent extends StatelessWidget {
  const EntriesEmptyContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyContent(
      message: 'You don\'t have any entries yet.',
      child: AppButton(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Add an Entry',
            style: TextStyle(fontSize: 30.0),
          ),
        ),
        onPressed: () {
          Env.store.dispatch(EntrySetNew());
          Get.toNamed(ExpenseRoutes.addEditEntries);
        },
      ),
    );
  }
}
