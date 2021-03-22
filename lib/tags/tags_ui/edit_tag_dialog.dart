import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../env.dart';
import '../../store/actions/single_entry_actions.dart';
import '../tag_model/tag.dart';

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
  bool canSave;

  void initState() {
    _controller = TextEditingController();
    _controller.value = TextEditingValue(text: widget.tag.name);
    canSave = _controller.text != null && _controller.text.length > 0;
    super.initState();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //TODO move to app dialog
    return AlertDialog(
      title: Text('Tag Editor'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9\-_\s]"))
        ],
        decoration: InputDecoration(border: OutlineInputBorder()),
        onChanged: (value) {
          setState(() {
            canSave = value != null && value.length > 0;
          });
        },
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            TextButton(
                child: Text('Delete'),
                onPressed: () => {
                      Env.store.dispatch(EntryDeleteTag(tag: widget.tag)),
                      Get.back(),
                    }),
            TextButton(
              child: Text('Cancel'),
              onPressed: () => {
                Get.back(),
              },
            ),
            TextButton(
              child: Text('Save'),
              //TODO this does not work
              onPressed: canSave
                  ? () => {
                        Env.store.dispatch(EntryAddUpdateTag(
                            tag: widget.tag
                                .copyWith(name: _controller.text.trimRight()))),
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
