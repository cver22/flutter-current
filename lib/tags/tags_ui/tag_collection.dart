import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_chip.dart';
import 'package:flutter/material.dart';

class TagCollection extends StatelessWidget {
  final List<Tag> tags;
  final String collectionName;

  const TagCollection({Key key, @required this.tags, @required this.collectionName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> tagChips = [];

    tags.forEach((tag) {
      tagChips.add(TagChip(tag: tag));
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
}
