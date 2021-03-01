import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDialog extends StatelessWidget {
  final Widget child;
  final VoidCallback backChevron;
  final Widget trailingTitleWidget;
  final String title;

  const AppDialog(
      {Key key, @required this.child, @required this.title, this.backChevron, this.trailingTitleWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(DIALOG_EDGE_INSETS),
      elevation: DIALOG_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DIALOG_BORDER_RADIUS)),
      child: DialogContent(backChevron: backChevron, title: title, trailingTitleWidget: trailingTitleWidget, child: child),
    );
  }
}


class AppDialogWithActions extends StatelessWidget {
  final Widget child;
  final VoidCallback backChevron;
  final Widget trailingTitleWidget;
  final String title;
  final Widget actions;

  const AppDialogWithActions(
      {Key key, @required this.child, @required this.title, this.actions, this.backChevron, this.trailingTitleWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(DIALOG_EDGE_INSETS),
      elevation: DIALOG_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DIALOG_BORDER_RADIUS)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DialogContent(backChevron: backChevron, title: title, trailingTitleWidget: trailingTitleWidget, child: child),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: actions ?? Container(),
          ),
        ],
      ),
    );
  }
}

class DialogContent extends StatelessWidget {
  const DialogContent({
    Key key,
    @required this.backChevron,
    @required this.title,
    @required this.trailingTitleWidget,
    @required this.child,
  }) : super(key: key);

  final VoidCallback backChevron;
  final String title;
  final Widget trailingTitleWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.chevron_left),
              //if no back action is passed, automatically set to pop context
              onPressed: () => backChevron ?? Get.back(),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 20.0),
            ),
            trailingTitleWidget == null ? Container() : trailingTitleWidget,
          ],
        ),
        //shows this list view if the category list comes from the log
        child,
      ],
    );
  }
}