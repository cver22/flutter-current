import 'package:emojis/emoji.dart';
import 'package:expenses/entry/entry_model/entries_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_collection.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class TagPicker extends StatefulWidget {
  @override
  _TagPickerState createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Tag> _logAllTags = [];
  List<String> _selectedEntryTags = [], _categoryRecentTags = [], _logRecentTags = [];
  Map<String, int> _categoryAllTags = {};
  Tag _currentTag;
  MyEntry _entry;
  Log _log;
  bool newTag = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text.toLowerCase();
      _controller.value = _controller.value.copyWith(
        text: text,
        selection: TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (entriesState) {
          int maxTags = 10;
          _entry = entriesState.selectedEntry.value;
          _tagListBuilders(maxTags);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: EMOJI_SIZE,
                    ),
                  ),
                  TextFormField(
                    key: _formKey,
                    decoration: InputDecoration(hintText: 'Tag your transaction'),
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    validator: (name) {
                      Pattern pattern = r'^[A-Za-z0-9]+(?:[_-][A-Za-z0-9]+)*$';
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(name))
                        return 'Invalid tag';
                      else
                        return null;
                    },
                  ),
                  IconButton(
                      icon: newTag ? Icon(Icons.add) : Icon(Icons.check),
                      onPressed: () {
                        //can be used to edit
                        if (_formKey.currentState.validate()) {
                          _currentTag = _currentTag.copyWith(name: _controller.text);
                          if (_currentTag.id == null) {
                            newTag = true;
                          }
                          Env.logsFetcher.updateLog(_log.addEditLogTags(log: _log, tag: _currentTag));
                          if (!_selectedEntryTags.contains(_currentTag.id) && newTag) {
                            _selectedEntryTags.add(_currentTag.id);
                            Env.store.dispatch(UpdateSelectedEntry(tagIDs: _selectedEntryTags));
                          }
                          _controller.clear();
                        }
                      }),
                ],
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

  void _tagListBuilders(int maxTags) {
    //builds their respective preliminary tag lists if the entry has a log and a category
    if (_entry?.logId != null) {
      _log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == _entry.logId);

      _logAllTags = _log.tags;

      if (_entry?.categoryId != null) {
        _log = Env.store.state.logsState.logs.values.firstWhere((e) => e.id == _entry.logId);

        //access the map of category tags based on selected log and selected category
        _categoryAllTags = _log.categories.firstWhere((e) => e.id == _entry.categoryId).tagIdFrequency;
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
      _logAllTags = _logAllTags.reversed;
      int i = 0;
      while (i < maxTags || i < _logAllTags.length) {
        //if the tag isn't in the log top 10, add it to the recent log tag list
        if (_categoryAllTags.isNotEmpty && !_categoryAllTags.containsKey(_logAllTags[i].id)) {
          _logRecentTags.add(_logAllTags[i].id);
          i++;
        } else if (_categoryAllTags.isEmpty) {
          //if there is no category selected yet, all top ten log tags get added to the recent log tag list
          _logRecentTags.add(_logAllTags[i].id);
          i++;
        }
      }
    }
  }

  void _buildCategoryRecentTagList() {
    if (_categoryAllTags.isNotEmpty) {
      List<String> keys = _categoryAllTags.keys.toList();
      keys.sort((k1, k2) {
        //compares frequency of one tag vs another from the category map
        if (_categoryAllTags[k1] > _categoryAllTags[k2]) return -1;
        if (_categoryAllTags[k1] < _categoryAllTags[k2]) return 1;
        return 0;
      });
      //reverses order of the key list
      keys = keys.reversed;

      //passes tags to the recent category tag list until max tags are reached
      for (int i = 0; i < keys.length; i++) {
        _categoryRecentTags.add(_logAllTags.firstWhere((e) => e.id == keys[i]).id);
      }
    }
  }

  void _buildEntryTagList() {
    List<String> entryTagIDs = _entry.tagIDs;
    for (int i = 0; i < entryTagIDs.length; i++) {
      _selectedEntryTags.add(_log.tags.firstWhere((e) => e.id == entryTagIDs[i]).id);
    }
  }
}

//TODO tag editor
//TODO tag creator
