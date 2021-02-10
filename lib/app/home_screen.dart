import 'package:expenses/app/splash_screen.dart';
import 'package:expenses/auth_user/models/auth_state.dart';
import 'package:expenses/env.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//first screen we see when opening the app, used to direct the user to sign in/up if they have not already
//signed in users have their content loaded, once the content is loaded, the user is directed to the AppScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState<AuthState>(
      where: notIdentical,
      map: (state) => state.authState,
      builder: (authState) {
        print('Rendering Home Screen');

        //Prevents calling in the current build cycle
        if (authState.user.isSome && authState.isLoading == false) {
          Env.settingsFetcher.readResetAppSettings(resetSettings: false);
          Env.logsFetcher.loadLogs();
          Env.tagFetcher.loadTags();
          Env.entriesFetcher.loadEntries();
          Env.userFetcher.isUserSignedInWithEmail();

          Future.delayed(Duration.zero, () {
            Get.offAllNamed(ExpenseRoutes.app);
          });
          /*Navigator.pushNamedAndRemoveUntil(context, ExpenseRoutes.app,
                ModalRoute.withName(ExpenseRoutes.home));*/
        } else if (authState.user.isNone && authState.isLoading == false) {
          Future.delayed(Duration.zero, () {
            Get.offAllNamed(ExpenseRoutes.loginRegister);
          });
          /* Navigator.pushNamedAndRemoveUntil(
                context,
                ExpenseRoutes.loginRegister,
                ModalRoute.withName(ExpenseRoutes.home));*/
        }
        return SplashScreen();
      },
    );
  }
}
