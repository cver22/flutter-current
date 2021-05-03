import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../env.dart';
import '../login_register_model/login_reg_state.dart';

class GoogleLoginButton extends StatelessWidget {
  final bool? enabled;
  final LoginRegState? loginRegState;

  const GoogleLoginButton({Key? key, this.enabled, this.loginRegState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        primary: enabled! ? Colors.redAccent : Colors.grey,
      ),
      icon: Icon(
        FontAwesomeIcons.google,
        color: Colors.white,
      ),
      label: Text('Sign in with Google', style: TextStyle(color: Colors.white)),
      onPressed: () =>
          enabled! ? Env.userFetcher.signInWithGoogle(loginRegState) : null,
    );
  }
}
