import 'package:expenses/tags/tag_model/tag.dart';
import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final VoidCallback onEdit;

  //TODO have chips change colour when selected?

  const TagChip({Key key, this.name, this.onPressed, this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(label: Text('#${name}'), onPressed: onPressed);
  }
}
