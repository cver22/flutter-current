import 'package:expenses/entry/entry_model/entry_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_collection.dart';
import 'package:expenses/tags/tags_ui/tag_editor.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class TagPicker extends StatefulWidget {
  @override
  _TagPickerState createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  List<Tag> _logAllTags = [], _selectedEntryTags = [], _categoryRecentTags = [], _logRecentTags = [];

  Map<String, int> _categoryAllTags = {};
  MyEntry _entry;
  Log _log;

  //TODO change this to function as a stateless widget driven by entryState, will need to dump the entry tags into the state tags at the beginning
  //TODO possible inherent problem with this may be the duplication of tags in the state
  //TODO can likely handle editing of log tags by collecting them in a state of edited tags and doing a dump of them when navigating back from the entry editor

  @override
  Widget build(BuildContext context) {
    return ConnectState<EntryState>(
        where: notIdentical,
        map: (state) => state.entryState,
        builder: (entryState) {
          int maxTags = 10;
          _entry = entryState.selectedEntry.value;
          _tagListBuilders(maxTags: maxTags, entryState: entryState);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagEditor(
                log: _log,
                onSave: () {
                  setState(() {});
                },
              ),

              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TagCollection(
                      tags: _selectedEntryTags,
                      entry: _entry,
                      entryState: entryState,
                      collectionName: 'Entry Tags',
                      tagCollectionType: TagCollectionType.entry,
                    ),
                    //currently selected tags
                    _categoryRecentTags.isNotEmpty
                        ? TagCollection(
                            tags: _categoryRecentTags,
                            entry: _entry,
                            entryState: entryState,
                            collectionName: 'Category Recent',
                            tagCollectionType: TagCollectionType.category,
                          )
                        : Container(),
                    //category recent tag collection
                    _logRecentTags.isNotEmpty
                        ? TagCollection(
                            tags: _logRecentTags,
                            entry: _entry,
                            entryState: entryState,
                            collectionName: 'Log Recent',
                            tagCollectionType: TagCollectionType.log,
                          )
                        : Container(),
                    //log recent tag collection
                  ],
                ),
              ), //log tag collection
            ],
          );
        });
  }

  void _tagListBuilders({@required EntryState entryState, int maxTags}) {
    //builds their respective preliminary tag lists if the entry has a log and a category
    if (_entry?.logId != null) {
      _log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == _entry.logId);

      _logAllTags = entryState.logTagList;

      if (_entry?.categoryId != null) {
        print('set category tags');

        //access the map of category tags based on selected log and selected category
        _categoryAllTags = _log.categories.firstWhere((e) => e.id == _entry.categoryId).tagIdFrequency ?? {};
      }
    }

    _buildEntryTagList();
    _buildCategoryRecentTagList();
    _buildLogRecentTagList(maxTags);
  }

  void _buildLogRecentTagList(int maxTags) {
    if (_logAllTags.isNotEmpty) {
      //adds logs tags to the tags list until max tags is reached

      _logAllTags.sort((a, b) => a.logFrequency.compareTo(b.logFrequency));
      _logAllTags = _logAllTags.reversed.toList();
      int tagCount = 0;
      int index = 0;
      _logRecentTags.clear();
      //TODO need to check if the tags are present in the entry first
      Map<String, Tag> selectedEntryMap = Map.fromIterable(_selectedEntryTags, key: (e) => e.id, value: (e) => e);

      while (tagCount < maxTags) {
        //if the tag isn't in the category top 10, add it to the recent log tag list
        if (!_categoryAllTags.containsKey(_logAllTags[index].id) &&
            !selectedEntryMap.containsKey(_logAllTags[index].id)) {
          //add to log list

          _logRecentTags.add(_logAllTags[index]);
          tagCount++;
        }
        index++;
        if (index >= _logAllTags.length) {
          break;
        }
      }
    }
  }

  void _buildCategoryRecentTagList() {
    if (_categoryAllTags.isNotEmpty) {
      _categoryRecentTags.clear();
      List<String> keys = _categoryAllTags.keys.toList();
      keys.sort((k1, k2) {
        //compares frequency of one tag vs another from the category map
        if (_categoryAllTags[k1] > _categoryAllTags[k2]) return -1;
        if (_categoryAllTags[k1] < _categoryAllTags[k2]) return 1;
        return 0;
      });
      //reverses order of the key list
      keys = keys.reversed.toList();

      //passes tags to the recent category tag list until max tags are reached
      for (int i = 0; i < keys.length; i++) {
        _categoryRecentTags.add(_logAllTags.firstWhere((e) => e.id == keys[i]));
      }
    }
    print('category tags: $_categoryRecentTags');
  }

  void _buildEntryTagList() {
    List<String> entryTagIDs = _entry?.tagIDs == null ? null : _entry.tagIDs;
    print('the entry tags are $entryTagIDs');
    _selectedEntryTags.clear();
    if (entryTagIDs != null && entryTagIDs.isNotEmpty) {
      for (int i = 0; i < entryTagIDs.length; i++) {
        _selectedEntryTags.add(_logAllTags.firstWhere((e) => e.id == entryTagIDs[i]));
      }
    } else {
      _selectedEntryTags = [];
    }
  }
}

//TODO tag editor
//TODO tag creator
