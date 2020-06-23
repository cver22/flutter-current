import 'package:expenses/env.dart';
import 'package:expenses/models/login_register/login__reg_status.dart';
import 'package:expenses/models/login_register/login_or_register.dart';
import 'package:expenses/models/login_register/login_reg_state.dart';
import 'package:expenses/screens/login/login_register_form.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState<LoginRegState>(
      where: notIdentical,
      map: (state) => state.loginRegState,
      builder: (state) {
        if (state.loginStatus == LoginStatus.success) {
          Env.userFetcher.startApp();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state.loginOrRegister == LoginOrRegister.login
                    ? 'Login'
                    : 'Register',
              ),
            ),
            body: LoginRegisterForm(),
          );
        }

        return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
