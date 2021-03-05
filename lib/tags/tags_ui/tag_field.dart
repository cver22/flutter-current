import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';

class TagField extends StatefulWidget {
  final FocusNode tagFocusNode;
  final bool searchOnly;

  TagField({
    Key key,
    @required this.tagFocusNode,
    this.searchOnly = false,
  }) : super(key: key);

  @override
  _TagFieldState createState() => _TagFieldState();
}

class _TagFieldState extends State<TagField> {
  TextEditingController _controller;
  bool canSave = false;
  bool searchOnly = false;

  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FocusNode tagFocusNode = widget.tagFocusNode;
    searchOnly = widget.searchOnly;

    //clears text from field after a tag is selected as the action clears the search state
    if (Env.store.state.singleEntryState.search.isNone) {
      _controller.clear();
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
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
            decoration: InputDecoration(labelText: 'Tag'),
            focusNode: tagFocusNode,
            controller: _controller,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: searchOnly ? null : (_) {
              setState(() {
                if (canSave) {
                  _saveTag();
                  widget.tagFocusNode.requestFocus();
                }
              });
            },
            onChanged: searchOnly ? null /*TODO do something here to search tags*/: (value) {
              setState(() {
                Env.store.dispatch(EntryStateSetSearchedTags(search: value));
                canSave = value != null && value.length > 0;
              });
            },
          ),
        ),
        IconButton(
            icon: Icon(
              Icons.add,
              color: canSave ? Colors.black : Colors.grey,
            ),
            onPressed: canSave ? _saveTag : null),
      ],
    );
  }

  _saveTag() {
    //create new tag
    Env.store.dispatch(AddUpdateTagFromEntryScreen(tag: Tag(name: _controller.text)));
    _controller.clear();
    canSave = false;
  }
}
