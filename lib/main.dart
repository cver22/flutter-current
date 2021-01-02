import 'package:expenses/app/app_screen.dart';
import 'package:expenses/app/home_screen.dart';
import 'package:expenses/app/splash_screen.dart';
import 'package:expenses/entry/entry_screen/add_edit_entries_screen.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_ui/add_edit_log_Screen.dart';
import 'package:expenses/login_register/login_register_ui/login_register_screen.dart';
import 'package:expenses/qr_reader/qr_ui/qr_reader.dart';
import 'package:expenses/settings/settings_ui/account_screen.dart';

import 'package:expenses/settings/settings_ui/settings_screen.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Env.userFetcher.startApp(); // allows code before runApp
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
        GetPage(name: ExpenseRoutes.home, page: () => HomeScreen(key: ExpenseKeys.homeScreen)),
        GetPage(name: ExpenseRoutes.loginRegister, page: () => LoginRegisterScreen(key: ExpenseKeys.loginScreen)),
        GetPage(name: ExpenseRoutes.app, page: () => AppScreen(key: ExpenseKeys.appScreen)),
        GetPage(name: ExpenseRoutes.account, page: () => AccountScreen(key: ExpenseKeys.accountScreen)),
        GetPage(name: ExpenseRoutes.settings, page: () => SettingsScreen(key: ExpenseKeys.settingsScreen)),
        GetPage(name: ExpenseRoutes.addEditLog, page: () => AddEditLogScreen(key: ExpenseKeys.addEditLogScreen)),
        GetPage(
            name: ExpenseRoutes.addEditEntries,
            page: () => AddEditEntriesScreen(key: ExpenseKeys.addEditEntriesScreen)),

      ],
      initialRoute: ExpenseRoutes.home,
      key: ExpenseKeys.main,
    );
  }
}
