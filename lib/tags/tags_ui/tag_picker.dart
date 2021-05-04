import 'package:flutter/material.dart';

import '../../entry/entry_model/app_entry.dart';
import '../../entry/entry_model/single_entry_state.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../store/connect_state.dart';
import '../../utils/db_consts.dart';
import '../../utils/maybe.dart';
import '../../utils/utils.dart';
import '../tag_model/tag.dart';
import 'tag_collection.dart';
import 'tag_field.dart';

class TagPicker extends StatefulWidget {
  @override
  _TagPickerState createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  List<Tag?> logAllTags = [],
      selectedEntryTags = [],
      categoryRecentTags = [],
      subcategoryRecentTags = [],
      logRecentTags = [];

  late AppEntry entry;
  late Log log;
  SingleEntryState? currentSingleEntryState;

  //TODO change this to function as a stateless widget driven by entryState, will need to dump the entry tags into the state tags at the beginning
  //TODO can likely handle editing of log tags by collecting them in a state of edited tags and doing a dump of them when navigating back from the entry editor

  @override
  Widget build(BuildContext context) {
    return ConnectState<SingleEntryState>(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (singleEntryState) {
          print('Rendering tag picker');
          int maxTags = MAX_TAGS;

          //ensures the visible entry isn't reset while the entry is saving
          if (!singleEntryState.processing && singleEntryState.selectedEntry.isSome) {
            currentSingleEntryState = singleEntryState;
            entry = currentSingleEntryState!.selectedEntry.value;
          }

          tagListBuilders(maxTags: maxTags, entryState: currentSingleEntryState);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagField(tagFocusNode: singleEntryState.tagFocusNode.value),
              SizedBox(height: 10.0),
              _buildTagCollections(singleEntryState: singleEntryState), //log tag collection
            ],
          );
        });
  }

  SingleChildScrollView _buildTagCollections({required SingleEntryState singleEntryState}) {
    return SingleChildScrollView(
      child: Column(
        //currently selected tags
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (singleEntryState.search.isSome) _searchCollection(singleEntryState: singleEntryState),
          TagCollection(
            tags: selectedEntryTags,
            collectionName: 'Entry Tags',
            search: Maybe.none(),
          ),
          if (subcategoryRecentTags.isNotEmpty &&
              singleEntryState.search.isNone &&
              entry.subcategoryId != NO_SUBCATEGORY)
            TagCollection(
              tags: subcategoryRecentTags,
              collectionName: 'Subcategory Recent',
              search: Maybe.none(),
            ),
          if (categoryRecentTags.isNotEmpty && singleEntryState.search.isNone)
            TagCollection(
              tags: categoryRecentTags,
              collectionName: 'Category Recent',
              search: Maybe.none(),
            ),
          //category recent tag collection
          if (logRecentTags.isNotEmpty && singleEntryState.search.isNone)
            TagCollection(
              tags: logRecentTags,
              collectionName: 'Log Recent',
              search: Maybe.none(),
            ),
          //log recent tag collection
        ],
      ),
    );
  }

  void tagListBuilders({required SingleEntryState? entryState, required int maxTags}) {
    //Map<String, Tag> categoryTagMap = <String, Tag>{}; //all tags for the category
    Map<String?, int> categoryAllTags = <String?, int>{};
    //Map<String, Tag> subcategoryTagMap = <String, Tag>{};// tag frequency for the category
    Map<String?, int> subcategoryAllTags = <String?, int>{}; // tag frequency for the category
    //builds their respective preliminary tag lists if the entry has a log and a category

    log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == entry.logId);

    logAllTags = entryState!.tags.values.where((e) => e.logId == log.id).toList();

    //get all tags associated with that category
    entryState.tags.forEach((key, value) {
      if (value.tagCategoryFrequency.containsKey(entry.categoryId)) {
        //categoryTagMap.putIfAbsent(key, () => value);
        categoryAllTags.putIfAbsent(key,
            () => value.tagCategoryFrequency.entries.firstWhere((element) => element.key == entry.categoryId).value);
      }
    });

    //get all tags associated with that subcategory if not NO_SUBCATEGORY
    if (entry.subcategoryId != NO_SUBCATEGORY) {
      entryState.tags.forEach((key, value) {
        if (value.tagSubcategoryFrequency.containsKey(entry.subcategoryId)) {
          //subcategoryTagMap.putIfAbsent(key, () => value);
          subcategoryAllTags.putIfAbsent(
              key,
              () => value.tagSubcategoryFrequency.entries
                  .firstWhere((element) => element.key == entry.subcategoryId)
                  .value);
        }
      });
    }

    _buildEntryTagList();
    Map<String?, Tag?> selectedEntryMap = Map.fromIterable(selectedEntryTags, key: (e) => e.id, value: (e) => e);
    subcategoryRecentTags = _buildAppCategoryRecentTagList(
        maxTags: maxTags, selectedEntryMap: selectedEntryMap, appCategoryAllTags: subcategoryAllTags);
    categoryRecentTags = _buildAppCategoryRecentTagList(
        maxTags: maxTags,
        selectedEntryMap: selectedEntryMap,
        appCategoryAllTags: categoryAllTags,
        subcategoryRecentTags: Map.fromIterable(subcategoryRecentTags, key: (e) => e.id, value: (e) => e));
    _buildLogRecentTagList(maxTags: maxTags, selectedEntryMap: selectedEntryMap, categoryAllTags: categoryAllTags);
  }

  void _buildLogRecentTagList(
      {required int maxTags,
      required Map<String?, Tag?> selectedEntryMap,
      required Map<String?, int> categoryAllTags}) {
    if (logAllTags.isNotEmpty) {
      //adds logs tags to the tags list until max tags is reached

      logAllTags.sort((a, b) => a!.tagLogFrequency.compareTo(b!.tagLogFrequency));
      logAllTags = logAllTags.reversed.toList();
      int tagCount = 0;
      int index = 0;
      logRecentTags.clear();

      while (tagCount < maxTags) {
        //if the tag isn't in the category top 10, add it to the recent log tag list
        //TODO this method currently prevents the listing of any category tag in the log tag section, even if its not one of the top 10, should that be the case?
        if (!categoryAllTags.containsKey(logAllTags[index]!.id) &&
            !selectedEntryMap.containsKey(logAllTags[index]!.id)) {
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

  List<Tag?> _buildAppCategoryRecentTagList(
      {required int maxTags,
      required Map<String?, Tag?> selectedEntryMap,
      required Map<String?, int> appCategoryAllTags,
      Map<String?, Tag?> subcategoryRecentTags = const {}}) {
    List<Tag?> appCategoryTags = <Tag?>[];

    if (appCategoryAllTags.isNotEmpty) {
      List<String?> recentCategoryKeys = appCategoryAllTags.keys.toList();
      recentCategoryKeys.sort((k1, k2) {
        //compares frequency of one tag vs another from the category map
        if (appCategoryAllTags[k1]! > appCategoryAllTags[k2]!) return -1;
        if (appCategoryAllTags[k1]! < appCategoryAllTags[k2]!) return 1;
        return 0;
      });
      //reverses order of the key list
      recentCategoryKeys = recentCategoryKeys.reversed.toList();
      int tagCount = 0;
      int index = 0;

      //passes tags to the recent category tag list until max tags are reached
      while (tagCount < maxTags) {
        //if the tag isn't in the selected entry tag list
        if (!selectedEntryMap.containsKey(recentCategoryKeys[index]) &&
            !subcategoryRecentTags.containsKey(recentCategoryKeys[index])) {
          //add to category list

          appCategoryTags.add(logAllTags.firstWhere((e) => e!.id == recentCategoryKeys[index]));
          tagCount++;
        }
        index++;
        if (index >= recentCategoryKeys.length) {
          break;
        }
      }
    }
    return appCategoryTags;
  }

  void _buildEntryTagList() {
    List<String> entryTagIDs = entry.tagIDs;
    selectedEntryTags.clear();
    if (entryTagIDs.isNotEmpty) {
      for (int i = 0; i < entryTagIDs.length; i++) {
        //if the tag is lost somehow, do not try to display the tag
        //TODO should this also remove a lost tag?
        Tag? tag = logAllTags.firstWhere((e) => e!.id == entryTagIDs[i], orElse: () => null);
        if (tag != null) {
          selectedEntryTags.add(tag);
        }
      }
    } else {
      selectedEntryTags = [];
    }
  }

  Widget _searchCollection({required SingleEntryState singleEntryState}) {
    if (singleEntryState.searchedTags.isNotEmpty) {
      return TagCollection(
        search: singleEntryState.search,
        tags: singleEntryState.searchedTags,
        collectionName: 'Searched Tags',
      );
    } else {
      return Text('Search: No matching #Tags, please add a #Tag');
    }
  }
}
