import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SimpleConfirmationDialog extends StatelessWidget {
  final Function(bool) onTapConfirm;
  final Function(bool)? onTapDiscard;
  final String title;
  final String? content;
  final String? confirmText;
  final bool canConfirm;

  const SimpleConfirmationDialog({Key? key, required this.onTapConfirm, this.onTapDiscard, required this.title, this.content, this.confirmText, this.canConfirm = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content == null ? Container(height: 0.0) : Container(child: Text(content!)),
      actions: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  onTapConfirm(false); //does not exit calling screen if used in willPopScope
                  Get.back();
                }),
            onTapDiscard != null ? TextButton(
                child: Text('Discard'),
                onPressed: () {
                  onTapDiscard!(true); //does not exit calling screen if used in willPopScope
                  Get.back();
                }) : Container(),
            canConfirm ? TextButton(
              child: Text(confirmText ??'Yes'),
              onPressed: () {
                onTapConfirm(true);
                Get.back();
              },
            ) : Container(),
          ],
        )
      ],
    );
  }
}
