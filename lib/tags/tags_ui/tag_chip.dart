
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/edit_tag_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class TagChip extends StatelessWidget {
  final Tag tag;

  //TODO have chips change colour when selected?

  const TagChip({Key key, this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey key = GlobalKey(debugLabel: tag.id);
    return InputChip(
      label: Text('#${tag.name}'),
      key: key,
      onPressed: () {
        Env.store.dispatch(SelectDeselectEntryTag(tag: tag));
      },
      onDeleted: () {
        Get.dialog(EditTagDialog(tag: tag));
      },
      deleteIcon: Icon(Icons.edit_outlined),
    );
  }
}
