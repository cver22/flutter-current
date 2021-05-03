import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../store/connect_state.dart';
import '../../utils/utils.dart';
import '../login_register_model/login_or_register.dart';
import '../login_register_model/login_reg_state.dart';
import 'login_register_form.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState<LoginRegState>(
      where: notIdentical,
      map: (state) => state.loginRegState,
      builder: (loginRegState) {
        print('Rendering Login Register Screen');

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
          onWillPop: (() =>
              SystemChannels.platform.invokeMethod('SystemNavigator.pop') as Future<bool>) as Future<bool> Function()?,
        );
      },
    );
  }
}
