import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/selected_tag_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class TagEditor extends StatefulWidget {
  final List<String> selectedEntryTags;
  final Log log;

  const TagEditor({Key key, @required this.selectedEntryTags, @required this.log}) : super(key: key);

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _selectedEntryTags;
  Log _log;

  Tag _selectedTag;
  bool newTag = false;

  @override
  void initState() {
    super.initState();
    _selectedEntryTags = widget?.selectedEntryTags;
    _log = widget?.log;
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
    return ConnectState<SelectedTagState>(
        where: notIdentical,
        map: (state) => state.selectedTagState,
        builder: (tagState) {
          _selectedTag = tagState.selectedTag.value;
          return Row(
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
                  icon: _selectedTag.id != null ? Icon(Icons.add) : Icon(Icons.check),
                  onPressed: () {
                    //can be used to edit
                    //TODO modify this to use selected tag State?
                    if (_formKey.currentState.validate()) {
                      _selectedTag = _selectedTag.copyWith(name: _controller.text);
                      if (_selectedTag.id == null) {
                        newTag = true;
                      }
                      Env.logsFetcher.updateLog(_log.addEditLogTags(log: _log, tag: _selectedTag));
                      if (!_selectedEntryTags.contains(_selectedTag.id) && newTag) {
                        _selectedEntryTags.add(_selectedTag.id);
                        Env.store.dispatch(UpdateSelectedEntry(tagIDs: _selectedEntryTags));
                      }
                      _controller.clear();
                    }
                  }),
            ],
          );
        });
  }
}
