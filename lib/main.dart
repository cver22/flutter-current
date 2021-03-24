
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'account/account_ui/account_screen.dart';
import 'app/app_screen.dart';
import 'app/home_screen.dart';
import 'entry/entry_screen/add_edit_entry_screen.dart';
import 'env.dart';
import 'log/log_ui/add_edit_log_Screen.dart';
import 'login_register/login_register_ui/login_register_screen.dart';
import 'settings/settings_ui/settings_screen.dart';
import 'utils/expense_routes.dart';
import 'utils/keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Env.userFetcher.startApp(); // allows code before runApp
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: [
        GetPage(
            name: ExpenseRoutes.home,
            page: () => HomeScreen(key: ExpenseKeys.homeScreen)),
        GetPage(
            name: ExpenseRoutes.loginRegister,
            page: () => LoginRegisterScreen(key: ExpenseKeys.loginScreen)),
        GetPage(
            name: ExpenseRoutes.app,
            page: () => AppScreen(key: ExpenseKeys.appScreen)),
        GetPage(
            name: ExpenseRoutes.account,
            page: () => AccountScreen(key: ExpenseKeys.accountScreen)),
        GetPage(
            name: ExpenseRoutes.settings,
            page: () => SettingsScreen(key: ExpenseKeys.settingsScreen)),
        GetPage(
            name: ExpenseRoutes.addEditLog,
            page: () => AddEditLogScreen(key: ExpenseKeys.addEditLogScreen)),
        GetPage(
            name: ExpenseRoutes.addEditEntries,
            page: () =>
                AddEditEntryScreen(key: ExpenseKeys.addEditEntriesScreen)),
      ],
      initialRoute: ExpenseRoutes.home,
      key: ExpenseKeys.main,
    );
  }
}
