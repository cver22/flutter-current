import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/entry/entry_model/entry_state.dart';

import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';

import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../env.dart';

class TagEditor extends StatefulWidget {
  final Log log;
  final VoidCallback onSave;

  const TagEditor({Key key, @required this.log, @required this.onSave}) : super(key: key);

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Tag _selectedTag;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final text = _controller.text;
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
    return ConnectState<EntryState>(
        where: notIdentical,
        map: (state) => state.entryState,
        builder: (entryState) {
          _selectedTag = entryState.selectedTag.isSome ? entryState.selectedTag.value : Tag();
          return Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                '#',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: EMOJI_SIZE,
                ),
              ),
              Expanded(
                child: TextFormField(
                  key: _formKey,
                  decoration: InputDecoration(hintText: 'Tag your transaction'),
                  controller: _controller,
                  keyboardType: TextInputType.text,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9\-_\s]"))],
                  onChanged: (text) {
                    setState(() {});
                  },
                ),
              ),
              IconButton(
                  icon: _selectedTag.id == null ? Icon(Icons.add) : Icon(Icons.check),
                  onPressed: _controller.text.isEmpty
                      ? null
                      : () {
                          //can be used to edit, needs modifications...a lot

                          _selectedTag = _selectedTag.copyWith(name: _controller.text);
                          _controller.clear();
                          if (_selectedTag.id == null) {

                            _selectedTag = _selectedTag.copyWith(id: Uuid().v4(), logFrequency: 1);

                            List<Tag> logTagList = entryState.logTagList;

                            logTagList.add(_selectedTag);
                            Env.store.dispatch(UpdateEntryState(logTagList: logTagList));
                            Env.store.dispatch(IncrementCategoryTagFrequency(categoryId: entryState.selectedEntry.value.categoryId, tagId: _selectedTag.id));

                            List<String> tagIds = entryState.selectedEntry.value.tagIDs;
                            tagIds.add(_selectedTag.id);
                            Env.store.dispatch(UpdateSelectedEntry(tagIDs: tagIds));
                            widget.onSave();
                          }
                        }),
            ],
          );
        });
  }
}
