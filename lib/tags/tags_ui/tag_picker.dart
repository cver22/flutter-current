import 'package:expenses/entry/entry_model/entries_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_collection.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class TagPicker extends StatefulWidget {
  @override
  _TagPickerState createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  List<Tag> _selectedEntryTags = [], _categoryRecentTags = [], _logAllTags = [], _logRecentTags = [];
  Map<String, int> _categoryAllTags = {};
  MyEntry _entry;
  Log _log;

  @override
  Widget build(BuildContext context) {
    return ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (entriesState) {
          _entry = entriesState.selectedEntry.value;

          if (_entry?.logId != null) {
            _log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == _entry.logId);

            _logAllTags = _log.tags;

            if (_entry?.categoryId != null) {
              _log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == _entry.logId);

              //access the map of category tags based on selected log and selected category
              _categoryAllTags = _log.categories.firstWhere((e) => e.id == _entry.categoryId).tagIdFrequency;
            }
          }

          //builds entry tag list
          List<String> entryTagIDs = _entry.tagIDs;
          for (int i = 0; i < entryTagIDs.length; i++) {
            _selectedEntryTags.add(_log.tags.firstWhere((e) => e.id == entryTagIDs[i]));
          }

          if (_logAllTags.isNotEmpty) {
            //adds logs tags to the tags list until max tags is reached
            int maxTags = 10;
            int currentTags = 0;
            List<Tag> tempTagList = [];
            //TODO iteration over list to find highest frequency

          }

          if (_categoryAllTags.isNotEmpty){
            //TODO iterate over map to find highest frequency
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(hintText: 'Tag your transaction'),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TagCollection(tags: _selectedEntryTags, entry: _entry, log: _log),
                    //currently selected tags
                    _categoryRecentTags.isNotEmpty
                        ? TagCollection(tags: _categoryRecentTags, entry: _entry, log: _log)
                        : Container(),
                    //category recent tag collection
                    _logRecentTags.isNotEmpty
                        ? TagCollection(tags: _logRecentTags, entry: _entry, log: _log)
                        : Container(),
                    //log recent tag collection
                  ],
                ),
              ), //log tag collection
            ],
          );
        });
  }
}

//TODO tag editor
//TODO tag creator
