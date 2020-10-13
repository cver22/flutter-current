import 'package:expenses/env.dart';
import 'package:expenses/screens/account/account_screen.dart';
import 'package:expenses/screens/app_screen.dart';
import 'package:expenses/screens/categories/category_list_dialog.dart';
import 'package:expenses/screens/entries/add_edit_entries_screen.dart';
import 'package:expenses/screens/home_screen.dart';
import 'package:expenses/screens/login/login_register_screen.dart';
import 'package:expenses/screens/logs/add_edit_log_Screen.dart';
import 'package:expenses/screens/setting/settings_screen.dart';
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
        GetPage(name: ExpenseRoutes.categories, page: () => CategoryListDialog(key: ExpenseKeys.categoriesDialog)),
      ],
      initialRoute: ExpenseRoutes.home,
      key: ExpenseKeys.main,
    );
  }
}
