import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/models/auth/auth_status.dart';
import 'package:expenses/screens/home_screen.dart';
import 'package:expenses/screens/login/login_screen.dart';
import 'package:expenses/screens/splash_screen.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // allows code before runApp
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ExpenseKeys.main,
      home: ConnectState<AuthState>(
          map: (state) => state.authState,
          where: notIdentical,
          builder: (authState) {
            print('Rendering Main Screen');

            if (authState.authStatus == AuthStatus.authenticated) {
              return HomeScreen(key: ExpenseKeys.homeScreen);
            } else if (authState.authStatus == AuthStatus.unauthenticated) {
              return LoginScreen(key: ExpenseKeys.loginScreen);
            }
            return SplashScreen(key: ExpenseKeys.splashScreen,);
          }),
    );
  }
}
