import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';

class TagEditor extends StatefulWidget {
  final List<Tag> selectedEntryTags;
  final Log log;
  final VoidCallback onSave;

  const TagEditor({Key key, @required this.selectedEntryTags, @required this.log, @required this.onSave}) : super(key: key);

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Tag> _newEntryTags;
  Log _log;

  Tag _selectedTag;
  bool newTag = false;

  @override
  void initState() {
    super.initState();
    _newEntryTags = [];
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
    return ConnectState<TagState>(
        where: notIdentical,
        map: (state) => state.tagState,
        builder: (tagState) {
          _selectedTag = tagState.selectedTag.isSome ? tagState.selectedTag.value : Tag();
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
                    setState(() {
                    });
                  },

                ),
              ),
              IconButton(
                  icon: _selectedTag.id != null ? Icon(Icons.add) : Icon(Icons.check),
                  onPressed: _controller.text.isEmpty ? null : () {
                    //can be used to edit, needs modifications...a lot

                    _selectedTag = _selectedTag.copyWith(name: _controller.text);
                    _controller.clear();
                    if(_selectedTag.id == null) {
                      newTag = true;
                      _newEntryTags.add(_selectedTag);
                      Env.store.dispatch(UpdateTagState(selectedTag: Maybe.some(_selectedTag), newTags: _newEntryTags));
                      widget.onSave();
                    }



                  }),
            ],
          );
        });
  }
}
