import 'package:hive/hive.dart';

import '../currency/currency_models/conversion_rates.dart';
import '../utils/db_consts.dart';

import 'splash_screen.dart';
import '../auth_user/models/auth_state.dart';
import '../env.dart';
import '../store/connect_state.dart';
import '../utils/expense_routes.dart';
import '../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//first screen we see when opening the app, used to direct the user to sign in/up if they have not already
//signed in users have their content loaded, once the content is loaded, the user is directed to the AppScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState<AuthState>(
      where: notIdentical,
      map: (state) => state.authState,
      builder: (authState) {
        print('Rendering Home Screen');

        //TODO add prints main, home, splash
        //move splashscreen to start of this, if no state?

        //Prevents calling in the current build cycle
        if (authState.user.isSome && authState.isLoading == false) {
          Env.logsFetcher.loadLogs();
          Env.tagFetcher.loadTags();
          Env.entriesFetcher.loadEntries();
          Env.userFetcher.isUserSignedInWithEmail();
          Env.currencyFetcher.localLoadAllConversionRates();

          Future.delayed(Duration.zero, () {
            Get.offAllNamed(ExpenseRoutes.app);
          });
        } else if (authState.user.isNone && authState.isLoading == false) {
          Future.delayed(Duration.zero, () {
            Get.offAllNamed(ExpenseRoutes.loginRegister);
          });
        }
        return LoadScreen();
      },
    );
  }
}
