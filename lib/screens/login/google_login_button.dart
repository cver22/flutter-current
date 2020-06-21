
import 'package:expenses/env.dart';
import 'package:expenses/models/login/login_reg_state.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleLoginButton extends StatelessWidget {

  final bool enabled;
  final LoginRegState loginRegState;

  const GoogleLoginButton({Key key, this.enabled, this.loginRegState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      icon: Icon(
        FontAwesomeIcons.google,
        color: Colors.white,
      ),
      label: Text('Sign in with Google', style: TextStyle(color: Colors.white)),
      color: enabled ? Colors.redAccent : Colors.grey,
      onPressed: () => enabled ? Env.userFetcher.signInWithGoogle(loginRegState) : null,
    );
  }
}
