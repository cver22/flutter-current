import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../env.dart';
import '../store/actions/account_actions.dart';
import '../utils/expense_routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: <Widget>[
        DrawerHeader(
          child: Text('Expense Tracker'),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListView(
              shrinkWrap: true,
              children: <Widget>[
                DrawerListTile(route: ExpenseRoutes.account, name: 'Account'),
                DrawerListTile(route: ExpenseRoutes.settings, name: 'Settings'),
              ],
            ),
          ],
        ),
      ],
    ));
  }
}

class DrawerListTile extends StatelessWidget {
  final String name;
  final String route;

  const DrawerListTile({
    required this.name,
    Key? key,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => SchedulerBinding.instance!.addPostFrameCallback((_) {
        Env.store.dispatch(AccountResetState());
        Get.back(); //pops drawer prior to opening next screen
        Get.toNamed(route);
      }),
      trailing: Icon(Icons.chevron_right),
      title: Text(name),
    );
  }
}
