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
      // ignore: missing_return
      builder: (authState) {
        if (authState.user.isSome) {
          //Prevents calling in the current build cycle
          Future.delayed(Duration.zero, () {
            Navigator.popUntil(context, ModalRoute.withName(ExpenseRoutes.home));
            Navigator.pushNamed(context, ExpenseRoutes.app);
          });
        } else if(authState.user.isNone) {
          Future.delayed(Duration(seconds: 2), () {
            Navigator.popUntil(context, ModalRoute.withName(ExpenseRoutes.home));
            Navigator.pushNamed(context, ExpenseRoutes.loginRegister);
          });
        }

        //TODO prevent returning to the splash screen with the back button
        return SplashScreen();
      },
    );
  }
}
