import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../env.dart';
import '../../store/actions/filter_actions.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../utils/db_consts.dart';
import '../tag_model/tag.dart';

class TagField extends StatefulWidget {
  final FocusNode tagFocusNode;
  final bool searchOnly;

  TagField({
    Key? key,
    required this.tagFocusNode,
    this.searchOnly = false,
  }) : super(key: key);

  @override
  _TagFieldState createState() => _TagFieldState();
}

class _TagFieldState extends State<TagField> {
  late TextEditingController _controller;
  bool hasData = false;
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

    if (Env.store.state.singleEntryState.search.isNone && !searchOnly) {
      //clears text for the entry search if a tag is selected
      _controller.clear();
    } else if (Env.store.state.filterState.tagSearch.isNone && searchOnly) {
      //clears text for filter state if a tag is selected
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
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]"))
            ],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: searchOnly
                ? null
                : (_) {
                    setState(() {
                      if (hasData) {
                        _saveTag();
                        widget.tagFocusNode.requestFocus();
                      }
                    });
                  },
            onChanged: (value) {
              setState(() {
                hasData = value.length > 0;

                if (searchOnly) {
                  Env.store.dispatch(FilterSetSearchedTags(search: value));
                } else {
                  Env.store.dispatch(EntrySetSearchedTags(search: value));
                }
              });
            },
          ),
        ),
        searchOnly
            ? IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  color: hasData ? Colors.black : Colors.grey,
                ),
                onPressed: hasData ? _clearSearch : null)
            : IconButton(
                icon: Icon(
                  Icons.add,
                  color: hasData ? Colors.black : Colors.grey,
                ),
                onPressed: hasData ? _saveTag : null),
      ],
    );
  }

  _saveTag() {
    //create new tag
    Env.store.dispatch(EntryAddUpdateTag(tag: Tag(name: _controller.text)));
    _controller.clear();
    hasData = false;
  }

  _clearSearch() {
    //create search
    Env.store.dispatch(FilterClearTagSearch());
    _controller.clear();
    hasData = false;
  }
}
