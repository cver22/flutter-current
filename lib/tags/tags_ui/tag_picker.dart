import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_collection.dart';
import 'package:expenses/tags/tags_ui/tag_creator.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class TagPicker extends StatefulWidget {
  @override
  _TagPickerState createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  List<Tag> logAllTags = [], selectedEntryTags = [], categoryRecentTags = [], logRecentTags = [];

  MyEntry entry;
  Log log;
  SingleEntryState currentSingleEntryState;

  //TODO change this to function as a stateless widget driven by entryState, will need to dump the entry tags into the state tags at the beginning
  //TODO can likely handle editing of log tags by collecting them in a state of edited tags and doing a dump of them when navigating back from the entry editor

  @override
  Widget build(BuildContext context) {
    return ConnectState<SingleEntryState>(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (singleEntryState) {
          print('Rendering tag picker');
          int maxTags = 10;

          //ensures the visible entry isn't reset while the entry is saving
          if (!singleEntryState.processing && singleEntryState.selectedEntry.isSome) {
            currentSingleEntryState = singleEntryState;
            entry = currentSingleEntryState.selectedEntry.value;
          }

          tagListBuilders(maxTags: maxTags, entryState: currentSingleEntryState);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagCreator(
              ),

              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TagCollection(
                      tags: selectedEntryTags,
                      collectionName: 'Entry Tags',
                    ),
                    //currently selected tags
                    categoryRecentTags.isNotEmpty
                        ? TagCollection(
                            tags: categoryRecentTags,
                            collectionName: 'Category Recent',
                          )
                        : Container(),
                    //category recent tag collection
                    logRecentTags.isNotEmpty
                        ? TagCollection(
                            tags: logRecentTags,
                            collectionName: 'Log Recent',
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
    Map<String, Tag> categoryTagMap = {}; //all tags for the category
    Map<String, int> categoryAllTags = {}; // tag frequency for the category
    //builds their respective preliminary tag lists if the entry has a log and a category
    if (entry?.logId != null) {
      log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == entry.logId);

      logAllTags = entryState.tags.values.where((e) => e.logId == log.id).toList();

      if (entry?.categoryId != null) {
        //if category is selected, get all tags associated with that category
        entryState.tags.forEach((key, value) {
          if (value.tagCategoryFrequency.containsKey(entry.categoryId)) {
            categoryTagMap.putIfAbsent(key, () => value);
            categoryAllTags.putIfAbsent(
                key,
                () =>
                    value.tagCategoryFrequency.entries.firstWhere((element) => element.key == entry.categoryId).value);
          }
        });
      }
    }

    _buildEntryTagList();
    Map<String, Tag> selectedEntryMap = Map.fromIterable(selectedEntryTags, key: (e) => e.id, value: (e) => e);
    _buildCategoryRecentTagList(maxTags: maxTags, selectedEntryMap: selectedEntryMap, categoryAllTags: categoryAllTags);
    _buildLogRecentTagList(maxTags: maxTags, selectedEntryMap: selectedEntryMap, categoryAllTags: categoryAllTags);
  }

  void _buildLogRecentTagList(
      {@required int maxTags,
      @required Map<String, Tag> selectedEntryMap,
      @required Map<String, int> categoryAllTags}) {
    if (logAllTags.isNotEmpty) {
      //adds logs tags to the tags list until max tags is reached

      logAllTags.sort((a, b) => a.tagLogFrequency.compareTo(b.tagLogFrequency));
      logAllTags = logAllTags.reversed.toList();
      int tagCount = 0;
      int index = 0;
      logRecentTags.clear();

      while (tagCount < maxTags) {
        //if the tag isn't in the category top 10, add it to the recent log tag list
        //TODO this method currently prevents the listing of any category tag in the log tag section, even if its not one of the top 10, should that be the case?
        if (!categoryAllTags.containsKey(logAllTags[index].id) && !selectedEntryMap.containsKey(logAllTags[index].id)) {
          //add to log list

          logRecentTags.add(logAllTags[index]);
          tagCount++;
        }
        index++;
        if (index >= logAllTags.length) {
          break;
        }
      }
    }
  }

  void _buildCategoryRecentTagList(
      {@required int maxTags,
      @required Map<String, Tag> selectedEntryMap,
      @required Map<String, int> categoryAllTags}) {
    //TODO figure out how to build the recent category tag list
    if (categoryAllTags.isNotEmpty) {
      categoryRecentTags.clear();
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

          categoryRecentTags.add(logAllTags.firstWhere((e) => e.id == recentCategoryKeys[index]));
          tagCount++;
        }
        index++;
        if (index >= recentCategoryKeys.length) {
          break;
        }
      }
    } else {
      //no tags present, reset the list
      categoryRecentTags = [];
    }
  }

  void _buildEntryTagList() {
    List<String> entryTagIDs = entry?.tagIDs == null ? null : entry.tagIDs;
    selectedEntryTags.clear();
    if (entryTagIDs != null && entryTagIDs.isNotEmpty) {
      for (int i = 0; i < entryTagIDs.length; i++) {
        //if the tag is lost somehow, do not try to display the tag
        //TODO should this also remove a lost tag?
        Tag tag = logAllTags?.firstWhere((e) => e.id == entryTagIDs[i], orElse: () => null);
        if (tag != null) {
          selectedEntryTags.add(tag);
        }
      }
    } else {
      selectedEntryTags = [];
    }
  }
}
