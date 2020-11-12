import 'package:flutter/material.dart';

class LoginRegisterButton extends StatelessWidget {
  final VoidCallback _onPressed;
  final String _name;

  const LoginRegisterButton({Key key, VoidCallback onPressed, String name})
      : _onPressed = onPressed,
        _name = name,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      onPressed: _onPressed,
      child: Text(_name),
    );
  }
}
