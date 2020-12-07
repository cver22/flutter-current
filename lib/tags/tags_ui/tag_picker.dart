import 'package:expenses/entry/entry_model/single_entry_state.dart';
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

  Map<String, int> categoryAllTags = {};
  MyEntry entry;
  Log _log;
  SingleEntryState currentSingleEntryState;

  //TODO change this to function as a stateless widget driven by entryState, will need to dump the entry tags into the state tags at the beginning
  //TODO possible inherent problem with this may be the duplication of tags in the state
  //TODO can likely handle editing of log tags by collecting them in a state of edited tags and doing a dump of them when navigating back from the entry editor

  @override
  Widget build(BuildContext context) {
    return ConnectState<SingleEntryState>(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (singleEntryState) {
          int maxTags = 10;

          //ensures the visible entry isn't reset while the entry is saving
          if (!singleEntryState.savingEntry && singleEntryState.selectedEntry.isSome) {
            currentSingleEntryState = singleEntryState;
            entry = currentSingleEntryState.selectedEntry.value;
          }

          tagListBuilders(maxTags: maxTags, entryState: currentSingleEntryState);

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
                      entry: entry,
                      entryState: currentSingleEntryState,
                      collectionName: 'Entry Tags',
                      tagCollectionType: TagCollectionType.entry,
                    ),
                    //currently selected tags
                    _categoryRecentTags.isNotEmpty
                        ? TagCollection(
                            tags: _categoryRecentTags,
                            entry: entry,
                            entryState: currentSingleEntryState,
                            collectionName: 'Category Recent',
                            tagCollectionType: TagCollectionType.category,
                          )
                        : Container(),
                    //category recent tag collection
                    _logRecentTags.isNotEmpty
                        ? TagCollection(
                            tags: _logRecentTags,
                            entry: entry,
                            entryState: currentSingleEntryState,
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

  void tagListBuilders({@required SingleEntryState entryState, int maxTags}) {
    //builds their respective preliminary tag lists if the entry has a log and a category
    if (entry?.logId != null) {
      _log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == entry.logId);

      _logAllTags = entryState.logTagList;

      if (entry?.categoryId != null) {

        //access the map of category tags based on selected log and selected category
        categoryAllTags = _log.categories.firstWhere((e) => e.id == entry.categoryId).tagIdFrequency ?? {};
      }
    }

    _buildEntryTagList();
    Map<String, Tag> selectedEntryMap = Map.fromIterable(_selectedEntryTags, key: (e) => e.id, value: (e) => e);
    _buildCategoryRecentTagList(maxTags: maxTags, selectedEntryMap: selectedEntryMap);
    _buildLogRecentTagList(maxTags: maxTags, selectedEntryMap: selectedEntryMap);
  }

  void _buildLogRecentTagList({@required int maxTags, @required Map<String, Tag> selectedEntryMap}) {
    if (_logAllTags.isNotEmpty) {
      //adds logs tags to the tags list until max tags is reached

      _logAllTags.sort((a, b) => a.logFrequency.compareTo(b.logFrequency));
      _logAllTags = _logAllTags.reversed.toList();
      int tagCount = 0;
      int index = 0;
      _logRecentTags.clear();

      while (tagCount < maxTags) {
        //if the tag isn't in the category top 10, add it to the recent log tag list
        if (!categoryAllTags.containsKey(_logAllTags[index].id) &&
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

  void _buildCategoryRecentTagList({@required int maxTags, @required Map<String, Tag> selectedEntryMap}) {
    if (categoryAllTags.isNotEmpty) {
      _categoryRecentTags.clear();
      List<String> recentCategoryKeys = categoryAllTags.keys.toList();
      recentCategoryKeys.sort((k1, k2) {
        //compares frequency of one tag vs another from the category map
        if (categoryAllTags[k1] > categoryAllTags[k2]) return -1;
        if (categoryAllTags[k1] < categoryAllTags[k2]) return 1;
        return 0;
      });
      //reverses order of the key list
      recentCategoryKeys = recentCategoryKeys.reversed.toList();
      int tagCount = 0;
      int index = 0;


      //passes tags to the recent category tag list until max tags are reached
      while (tagCount < maxTags) {
        //if the tag isn't in the selected entry tag list
        if (!selectedEntryMap.containsKey(recentCategoryKeys[index])) {
          //add to category list

          _categoryRecentTags.add(_logAllTags.firstWhere((e) => e.id == recentCategoryKeys[index]));
          tagCount++;
        }
        index++;
        if (index >= recentCategoryKeys.length) {
          break;
        }
      }
    } else {
      //no tags present, reset the list
      _categoryRecentTags = [];
    }
  }

  void _buildEntryTagList() {
    List<String> entryTagIDs = entry?.tagIDs == null ? null : entry.tagIDs;
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
