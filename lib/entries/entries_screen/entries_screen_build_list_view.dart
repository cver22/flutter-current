import 'package:expenses/entries/entries_screen/entry_list_tile.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class EntriesScreenBuildListView extends StatelessWidget {
  const EntriesScreenBuildListView({
    Key key,
    @required List<MyEntry> entries,
  })  : _entries = entries,
        super(key: key);

  final List<MyEntry> _entries;

  @override
  Widget build(BuildContext context) {
    Map<String, Tag> tags = Env.store.state.tagState.tags;

    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        itemCount: _entries.length,
        itemBuilder: (BuildContext context, int index) {
          final MyEntry _entry = _entries[index];
          return EntryListTile(entry: _entry, tags: tags);
        });
  }
}
