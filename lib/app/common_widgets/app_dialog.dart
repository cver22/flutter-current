import 'package:expenses/tags/tags_ui/tag_field.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDialogWithActions extends StatelessWidget {
  final Widget child;
  final VoidCallback backChevron;
  final Widget trailingTitleWidget;
  final String title;
  final List<Widget> actions;
  final bool shrinkWrap;
  final bool padContent;
  final Widget topWidget;

  const AppDialogWithActions(
      {Key key,
      @required this.child,
      @required this.title,
      this.actions,
      this.backChevron,
      this.trailingTitleWidget,
      this.shrinkWrap = false,
      this.padContent = true, this.topWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
      contentPadding: padContent ? EdgeInsets.fromLTRB(10, 0, 10, 0) : EdgeInsets.fromLTRB(0, 0, 0, 0),
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                //if no back action is passed, automatically set to pop context
                onPressed: backChevron ?? () => Get.back(),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 20.0),
              ),
              trailingTitleWidget == null
                  ? Opacity(
                      opacity: 0.0,
                      child: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: null,
                      ))
                  : trailingTitleWidget,
            ],
          ),
          topWidget ?? Container(),
        ],
      ),
      insetPadding: EdgeInsets.all(DIALOG_EDGE_INSETS),
      elevation: DIALOG_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DIALOG_BORDER_RADIUS)),
      actions: actions,
      actionsPadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
      content: Builder(builder: (context) {
        // Get available height and width of the build area of this widget. Make a choice depending on the size.
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;

        if (shrinkWrap) {
          return Container(
            width: width - DIALOG_EDGE_INSETS * 2,
            child: child,
          );
        } else {
          return Container(
            height: height - DIALOG_EDGE_INSETS * 2,
            width: width - DIALOG_EDGE_INSETS * 2,
            child: child,
          );
        }
      }),
    );
  }
}
