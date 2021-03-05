import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/edit_tag_dialog.dart';
import 'package:expenses/tags/tags_ui/tag_rich_text_spans.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final String search;
  final bool editable;

  //TODO have chips change colour when selected?

  const TagChip({Key key, @required this.tag, this.search, this.editable = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey key = GlobalKey(debugLabel: tag.id);

    RichText searchedText = tagRichTextSpans(tag: tag, search: search);

    return InputChip(
      label: searchedText == null ? Text('#${tag.name}') : searchedText,
      key: key,
      onPressed: () {
        Env.store.dispatch(SelectDeselectEntryTag(tag: tag));
      },
      onDeleted: editable ? () {
        Get.dialog(EditTagDialog(tag: tag)) ;
      }: null,
      deleteIcon: editable ? Icon(Icons.edit_outlined): Container(),
    );
  }



}
