import 'package:flutter/material.dart';

import '../../entry/entry_model/app_entry.dart';
import '../../env.dart';
import '../../tags/tag_model/tag.dart';
import 'entries_list_tile.dart';

class EntriesScreenBuildListView extends StatelessWidget {
  const EntriesScreenBuildListView({
    Key? key,
    required List<AppEntry>? entries,
  })  : _entries = entries,
        super(key: key);

  final List<AppEntry>? _entries;

  @override
  Widget build(BuildContext context) {
    Map<String, Tag> tags = Env.store.state.tagState.tags;

    return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding:
            const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        itemCount: _entries!.length,
        itemBuilder: (BuildContext context, int index) {
          final AppEntry _entry = _entries![index];
          return EntriesListTile(entry: _entry, tags: tags);
        });
  }
}
