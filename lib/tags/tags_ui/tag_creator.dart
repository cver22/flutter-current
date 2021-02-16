import 'package:expenses/store/actions/my_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';

class TagCreator extends StatefulWidget {
  final FocusNode tagFocusNode;

  TagCreator({
    Key key,
    @required this.tagFocusNode,
  }) : super(key: key);

  @override
  _TagCreatorState createState() => _TagCreatorState();
}

class _TagCreatorState extends State<TagCreator> {
  TextEditingController _controller;
  bool canSave = false;

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
            onFieldSubmitted: (_) {
              setState(() {
                if (canSave) {
                  _saveTag();
                  widget.tagFocusNode.requestFocus();
                }
              });
            },
            onChanged: (value) {
              setState(() {
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
