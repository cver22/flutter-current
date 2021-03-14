import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_chip.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:flutter/material.dart';

class TagCollection extends StatelessWidget {
  final List<Tag> tags;
  final String collectionName;
  final Maybe<String> search;
  final bool chipsEditable;
  final bool filterSelect;

  const TagCollection(
      {Key key,
      @required this.tags,
      this.collectionName,
      @required this.search,
      this.chipsEditable = true,
      this.filterSelect = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> tagChips = [];

    tags.forEach((tag) {
      tagChips.add(TagChip(
        tag: tag,
        search: search,
        editable: chipsEditable,
        filterSelect: filterSelect,
      ));
    });
    return Column(
      children: [
        collectionName == null ? Container() :Text(collectionName),
        Wrap(
          spacing: 5.0,
          runSpacing: 3.0,
          children: tagChips,
        ),
      ],
    );
  }
}
