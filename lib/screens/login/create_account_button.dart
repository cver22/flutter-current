import 'package:expenses/env.dart';
import 'package:expenses/models/login/login_or_register.dart';
import 'package:expenses/models/login/login_reg_state.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:flutter/material.dart';

class CreateAccountButton extends StatelessWidget {
  final LoginRegState loginState;

  const CreateAccountButton({Key key, this.loginState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Create an Account'),
      onPressed: () {
        Env.store.dispatch(UpdateLoginRegState(
            loginRegState: loginState.copyWith(
                loginOrRegister: _changeLoginRegister(loginState))));
      },
    );
  }

  LoginOrRegister _changeLoginRegister(LoginRegState loginState) {
    if(loginState.loginOrRegister == LoginOrRegister.login){
      return LoginOrRegister.register;
    } else{
      return LoginOrRegister.login;
    }
  }
}
