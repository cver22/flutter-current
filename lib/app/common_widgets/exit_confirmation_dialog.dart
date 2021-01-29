import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExitConfirmationDialog extends StatelessWidget {
  final VoidCallback onTap;
  final Function(bool) pop;
  final String title;

  const ExitConfirmationDialog({Key key, this.onTap, this.pop, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      actions: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () => {
                      pop(false),
                      Get.back(),
                    }),
            FlatButton(
              child: Text('Yes'),
              onPressed: () => {
                pop(true),
                Get.back(),
                onTap,
              },
            ),
          ],
        )
      ],
    );
  }
}
