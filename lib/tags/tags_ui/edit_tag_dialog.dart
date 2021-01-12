import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../env.dart';

class EditTagDialog extends StatefulWidget {
  final Tag tag;

  const EditTagDialog({
    Key key,
    this.tag,
  }) : super(key: key);

  @override
  _EditTagDialogState createState() => _EditTagDialogState();
}

class _EditTagDialogState extends State<EditTagDialog> {
  TextEditingController _controller;

  void initState() {
    _controller = TextEditingController();
    _controller.value = TextEditingValue(text: widget.tag.name);
    super.initState();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tag Editor'),
      content: TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9\-_\s]"))],
          decoration: InputDecoration(border: OutlineInputBorder())),
      actions: <Widget>[
        Row(
          children: <Widget>[
            FlatButton(
                child: Text('Delete'),
                onPressed: () => {
                      Env.store.dispatch(DeleteTagFromEntryScreen(tag: widget.tag)),
                      Get.back(),
                    }),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => {
                Get.back(),
              },
            ),
            FlatButton(
              child: Text('Save'),
              onPressed: _controller.text != null && _controller.text.length > 0
                  ? () => {
                        Env.store.dispatch(
                            AddUpdateTagFromEntryScreen(tag: widget.tag.copyWith(name: _controller.text.trimRight()))),
                        Get.back(),
                      }
                  : null,
            ),
          ],
        )
      ],
    );
  }
}
