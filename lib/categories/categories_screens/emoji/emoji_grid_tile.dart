import 'package:emojis/emoji.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class EmojiGridTile extends StatelessWidget {
  final String emojiChar;
  final Function(String) emojiSelection;

  EmojiGridTile({this.emojiChar, this.emojiSelection});

  @override
  Widget build(BuildContext context) {
    //TODO make button with onPressed
    return GridTile(
      child: Center(
        child: FlatButton(
          onPressed: () => {emojiSelection(emojiChar), print('$emojiChar ${Emoji.byChar(emojiChar).name}')},
          child: Text(
            '${Emoji.byChar(emojiChar)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: EMOJI_SIZE,
            ), //TODO media query
          ),
        ),
      ),
    );
  }
}
