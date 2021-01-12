import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';

class TagEditor extends StatefulWidget {
  final Log log;

  const TagEditor({Key key, @required this.log}) : super(key: key);

  @override
  _TagEditorState createState() => _TagEditorState();
}

class _TagEditorState extends State<TagEditor> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Tag selectedTag;

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
    return ConnectState<SingleEntryState>(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (singleEntryState) {
          selectedTag = singleEntryState.selectedTag.isSome ? singleEntryState.selectedTag.value : Tag();
          //TODO this rebuilds everytime, how to make that not happen?
          if (selectedTag?.name != null) {
            _controller.value = TextEditingValue(text: selectedTag.name);
          }
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
                    if (selectedTag.id == null) {
                      setState(() {});
                    }
                  },
                ),
              ),
              IconButton(
                  icon: Icon(
                    Icons.add,
                    color: _controller.text.isEmpty ? Colors.grey : Colors.black,
                  ),
                  onPressed: _controller.text.isEmpty
                      ? null
                      : () {
                          //passes the new or updated tag to actions to add or update as required
                          Env.store
                              .dispatch(AddUpdateTagFromEntryScreen(tag: selectedTag.copyWith(name: _controller.text)));
                          _controller.clear();
                        }),
            ],
          );
        });
  }
}
