import 'package:expenses/models/login_register/login_or_register.dart';
import 'package:expenses/models/login_register/login_reg_state.dart';
import 'package:expenses/screens/login/login_register_form.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginRegisterScreen extends StatelessWidget {
  const LoginRegisterScreen({Key key}) : super(key: key);

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

          onWillPop: () => SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
        );
      },
    );
  }
}
