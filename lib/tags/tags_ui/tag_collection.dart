import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/tags/tags_ui/tag_chip.dart';
import 'package:flutter/material.dart';

class TagCollection extends StatelessWidget {
  final List<String> tags;
  final MyEntry entry;
  final Log log;

  const TagCollection({Key key, @required this.tags, @required this.entry, @required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> tagChips = [];
    tags.forEach((id) {
      tagChips.add(TagChip(
        name: log.tags.firstWhere((e) => e.id == id).name,
      ));
    });
    return Wrap(
      spacing: 5.0,
      runSpacing: 3.0,
      children: tagChips,
    );
  }

//TODO maybe filter by what is typed
//TODO use tag state to pass onEdit to the selector


}
