import 'package:expenses/env.dart';
import 'package:expenses/screens/account/account_screen.dart';
import 'package:expenses/screens/app_screen.dart';
import 'package:expenses/screens/entries/add_edit_entries_screen.dart';
import 'package:expenses/screens/entries/entries_screen.dart';
import 'package:expenses/screens/home_screen.dart';
import 'package:expenses/screens/login/login_register_screen.dart';
import 'package:expenses/screens/logs/add_edit_log_Screen.dart';
import 'package:expenses/screens/logs/logs_screen.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/keys.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Env.userFetcher.startApp(); // allows code before runApp
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ExpenseRoutes.home: (context) {
          return HomeScreen(
            key: ExpenseKeys.homeScreen,
          );
        },
        ExpenseRoutes.loginRegister: (context) {
          return LoginRegisterScreen(key: ExpenseKeys.loginScreen);
        },
        ExpenseRoutes.app: (context) {
          return AppScreen(key: ExpenseKeys.appScreen);
        },
        ExpenseRoutes.account: (context) {
          return AccountScreen(key: ExpenseKeys.accountScreen);
        },
        ExpenseRoutes.addEditLog: (context) {
          return AddEditLogScreen(key: ExpenseKeys.addEditLogScreen);
        },
        ExpenseRoutes.addEditEntries: (context) {
          return AddEditEntriesScreen(key: ExpenseKeys.addEditEntriesScreen);
        },

        //TODO how to use these with tabs?
        /*ExpenseRoutes.logs: (context) {
          return LogsScreen(key: ExpenseKeys.logsScreen);
        },

        ExpenseRoutes.entries: (context) {
          return EntriesScreen(key: ExpenseKeys.entriesScreen);
        },
*/
      },
      initialRoute: ExpenseRoutes.home,
      key: ExpenseKeys.main,
    );
  }
}
