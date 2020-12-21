import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/entry/entry_screen/entry_list_tile.dart';
import 'package:flutter/material.dart';

class EntriesScreenBuildListView extends StatelessWidget {
  const EntriesScreenBuildListView({
    Key key,
    @required List<MyEntry> entries,
  })  : _entries = entries,
        super(key: key);

  final List<MyEntry> _entries;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        itemCount: _entries.length,
        itemBuilder: (BuildContext context, int index) {
          final MyEntry _entry = _entries[index];
          //TODO build filtered view options
          return EntryListTile(entry: _entry);
        });
  }
}
