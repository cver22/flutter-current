import 'package:flutter/material.dart';

class TagChip extends StatelessWidget {
  final String name;
  final VoidCallback onPressed;
  final VoidCallback onMenu;

  //TODO have chips change colour when selected?

  const TagChip({Key key, this.name, this.onPressed, this.onMenu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text('#$name'),
      onPressed: onPressed,
      onDeleted: onMenu,
      deleteIcon: Icon(Icons.more_vert_outlined),
    );
  }
}
