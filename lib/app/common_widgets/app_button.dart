import 'package:flutter/material.dart';

import '../../utils/db_consts.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.buttonColor,
  }) : super(key: key);

  final Function/*!*/ onPressed;
  final Widget child;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: ELEVATED_BUTTON_ELEVATION,
        primary: buttonColor ?? ThemeData.light().primaryColor,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ELEVATED_BUTTON_CIRCULAR_RADIUS)),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}
