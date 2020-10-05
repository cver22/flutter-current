import 'package:expenses/env.dart';
import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/screens/splash_screen.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState<AuthState>(
      where: notIdentical,
      map: (state) => state.authState,
      builder: (authState) {
        print('Rendering Home Screen');
        print('logged in user ${authState.user.toString()}');
        print('is loading ${authState.isLoading}');

        if (authState.user.isSome && authState.isLoading == false) {
          //Prevents calling in the current build cycle

          Env.store.state.settingsState.initializeSettings();
          print('current settings ${Env.store.state.settingsState.settings}');

          Future.delayed(Duration.zero, () {
            Navigator.pushNamedAndRemoveUntil(context, ExpenseRoutes.app,
                ModalRoute.withName(ExpenseRoutes.home));
          });
        } else if (authState.user.isNone && authState.isLoading == false) {
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pushNamedAndRemoveUntil(
                context,
                ExpenseRoutes.loginRegister,
                ModalRoute.withName(ExpenseRoutes.home));
          });
        }

        //TODO prevent returning to the splash screen with the back button
        return SplashScreen();
      },
    );
  }
}
