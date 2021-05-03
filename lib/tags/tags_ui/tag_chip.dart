import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';
import '../../store/actions/filter_actions.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../utils/maybe.dart';
import '../tag_model/tag.dart';
import 'edit_tag_dialog.dart';
import 'tag_rich_text_spans.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final Maybe<String> search;
  final bool editable;
  final bool filterSelect;

  //TODO have chips change colour when selected?

  const TagChip(
      {Key? key,
      required this.tag,
      required this.search,
      this.editable = true,
      this.filterSelect = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey key = GlobalKey(debugLabel: tag.id);

    RichText? searchedText = tagRichTextSpans(tag: tag, search: search);

    return InputChip(
      label: searchedText == null ? Text('#${tag.name}') : searchedText,
      key: key,
      onPressed: () {
        if (filterSelect) {
          Env.store.dispatch(FilterSelectDeselectTag(name: tag.name));
        } else {
          Env.store.dispatch(EntrySelectDeselectTag(tag: tag));
        }
      },
      onDeleted: editable
          ? () {
              Get.dialog(EditTagDialog(tag: tag));
            }
          : null,
      deleteIcon: editable ? Icon(Icons.edit_outlined) : Container(),
    );
  }
}
