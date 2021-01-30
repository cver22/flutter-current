import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';

class TagCreator extends StatefulWidget {
  TagCreator({
    Key key,
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
            decoration: InputDecoration(hintText: 'Tag your transaction'),
            controller: _controller,
            keyboardType: TextInputType.text,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9\-_\s]"))],
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
            onPressed: canSave
                ? () {
                    //create new tag
                    Env.store.dispatch(AddUpdateTagFromEntryScreen(tag: Tag(name: _controller.text)));
                    _controller.clear();
                  }
                : null),
      ],
    );
  }
}
