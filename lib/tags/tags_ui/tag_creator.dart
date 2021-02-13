import 'package:expenses/store/actions/my_actions.dart';
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
  FocusNode tagFocus = FocusNode();
  Map<Type, Action<Intent>> _actionsMap;
  Map<LogicalKeySet, Intent> _shortcutMap;

  void initState() {
    _controller = TextEditingController();
    _actionsMap = <Type, Action<Intent>> {
      ActivateIntent: CallbackAction<ActivateIntent>(
    onInvoke: (Intent intent) => { print('thing')}),
    };
    _shortcutMap = <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
    };
    super.initState();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /*_onEventKey(RawKeyEvent event) {
      print('triggered');
      print(event.character);

    }*/

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
          child: FocusableActionDetector(
            shortcuts: _shortcutMap,
            actions: _actionsMap,
            child: TextFormField(
              decoration: InputDecoration(hintText: 'Tag your transaction'),
              focusNode: tagFocus,
              controller: _controller,
              keyboardType: TextInputType.text,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))],
              onFieldSubmitted: (_) {
                setState(() {
                  _saveTag();
                  tagFocus.requestFocus();
                });
              },
              onChanged: (value) {
                setState(() {
                  canSave = value != null && value.length > 0;
                });
              },
            ),
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
