import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

class EmojiGridTile extends StatelessWidget {
  final String emojiChar;

  EmojiGridTile({this.emojiChar});

  @override
  Widget build(BuildContext context) {
    //TODO make button with onPressed
    return GridTile(
      child: Text(
        '${Emoji.byChar(emojiChar)}',
        style: TextStyle(fontSize: 25), //TODO media query
      ),
    );
  }
}
