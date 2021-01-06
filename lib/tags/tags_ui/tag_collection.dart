import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_chip.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class TagCollection extends StatelessWidget {
  final List<Tag> tags;
  final MyEntry entry;
  final SingleEntryState entryState;

  final String collectionName;
  final TagCollectionType tagCollectionType;

  const TagCollection(
      {Key key,
      @required this.tags,
      @required this.entry,
      @required this.collectionName,
      @required this.tagCollectionType,
      @required this.entryState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    List<Widget> tagChips = [];

    tags.forEach((thisTag) {
      tagChips.add(TagChip(
        name: thisTag.name,
        onPressed: () => {
          Env.store.dispatch(SelectDeselectEntryTag(tag: thisTag)),
        },
        onEdit: () => {
          Env.store.dispatch(EditTagFromEntryScreen(tag: thisTag)),
        },
        onDelete: () => {
          Env.store.dispatch(DeleteTagFromEntryScreen(tag: thisTag)),
        },
      ));
    });
    return Column(
      children: [
        Text(collectionName),
        Wrap(
          spacing: 5.0,
          runSpacing: 3.0,
          children: tagChips,
        ),
      ],
    );
  }

//TODO maybe filter by what is typed

}
