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
      builder: (loginRegState) {
        return WillPopScope(
          child: Scaffold(
            appBar: AppBar(
              leading: Container(),
              title: Text(
                loginRegState.loginOrRegister == LoginOrRegister.login
                    ? 'Login'
                    : 'Register',
              ),
            ),
            body: LoginRegisterForm(),
          ),
          onWillPop: () async {
            return false;
          },
        );
      },
    );
  }
}
