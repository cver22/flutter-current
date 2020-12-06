import 'package:expenses/env.dart';
import 'package:expenses/login_register/login_register_model/login_or_register.dart';
import 'package:expenses/login_register/login_register_model/login_reg_state.dart';

import 'package:expenses/store/actions/actions.dart';
import 'package:flutter/material.dart';

class CreateAccountButton extends StatelessWidget {
  final LoginRegState loginState;

  const CreateAccountButton({Key key, this.loginState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: loginState.loginOrRegister == LoginOrRegister.login ? Text('Create an Account') : Text('Go to Login'),
      onPressed: () {
        Env.store.dispatch(LoginOrCreateUser());
      },
    );
  }
}
