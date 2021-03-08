import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key key,
    @required this.onPressed,
    @required this.child, this.buttonColor,
  }) : super(key: key);

  final Function onPressed;
  final Widget child;
  final Color buttonColor;


  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      elevation: RAISED_BUTTON_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
      onPressed: onPressed,
      child: child,
      color: buttonColor ?? Theme.of(context).buttonColor,
    );
  }
}