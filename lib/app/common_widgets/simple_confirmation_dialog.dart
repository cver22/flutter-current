import 'package:flutter/material.dart';
import 'package:get/get.dart';

//used by the enty and log for confirming exit, delete actions
class SimpleConfirmationDialog extends StatelessWidget {
  final Function(bool) onTapYes;
  final String title;
  final String content;

  const SimpleConfirmationDialog({Key key, this.onTapYes, this.title, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content == null ? Container(height: 0.0) : Container(child: Text(content)),
      actions: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  onTapYes(false); //does not exit calling screen if used in willPopScope
                  Get.back();
                }),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                onTapYes(true);
                Get.back();
              },
            ),
          ],
        )
      ],
    );
  }
}
