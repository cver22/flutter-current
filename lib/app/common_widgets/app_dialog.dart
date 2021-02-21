import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final Widget child;

  const AppDialog({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(DIALOG_EDGE_INSETS),
      elevation: DIALOG_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DIALOG_BORDER_RADIUS)),
      child: child,
    );
    ;
  }
}
