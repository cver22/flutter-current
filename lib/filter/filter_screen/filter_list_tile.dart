import 'package:flutter/material.dart';

import '../../app/common_widgets/list_tile_components.dart';

class FilterListTile extends StatelessWidget {
  final bool selected;
  final VoidCallback onSelect;
  final String title;

  const FilterListTile(
      {Key key,
      @required this.selected,
      @required this.onSelect,
      @required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onSelect,
      title: Text(title),
      trailing: FilterListTileTrailing(
        selected: selected,
        onSelect: onSelect,
      ),
    );
  }
}
