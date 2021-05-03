import 'package:flutter/material.dart';

import '../../env.dart';
import '../../store/actions/login_reg_actions.dart';
import '../login_register_model/login_or_register.dart';
import '../login_register_model/login_reg_state.dart';

class CreateAccountButton extends StatelessWidget {
  final LoginRegState? loginState;

  const CreateAccountButton({Key? key, this.loginState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: loginState!.loginOrRegister == LoginOrRegister.login
          ? Text('Create an Account')
          : Text('Go to Login'),
      onPressed: () {
        Env.store.dispatch(LoginOrCreateUser());
      },
    );
  }
}
