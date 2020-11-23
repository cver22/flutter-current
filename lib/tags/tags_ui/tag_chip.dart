import 'package:expenses/tags/tag_model/tag.dart';
import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final VoidCallback onPressed;
  final VoidCallback onEdit;

  //TODO have chips change colour when selected?

  const TagChip({Key key, this.tag, this.onPressed, this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(label: Text(tag.name), onPressed: onPressed);
  }
}
