import 'package:emojis/emoji.dart';
import 'package:expenses/screens/categories/emoji/emoji_grid_tile.dart';
import 'package:flutter/material.dart';

class EmojiGrid extends StatelessWidget {
  final EmojiGroup emojiGroup;
  final Function(String) emojiSelection;

  EmojiGrid({@required this.emojiGroup, @required this.emojiSelection});

  //TODO on pressed method

  @override
  Widget build(BuildContext context) {
    List<String> charList = [];
    Emoji.all().where((element) => element.emojiGroup == emojiGroup).forEach((element) {
      charList.add(element.char);
    });

    return GridView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: charList.length,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8, crossAxisSpacing: 1.0, mainAxisSpacing: 1.0),
      itemBuilder: (BuildContext context, int index) {
        return EmojiGridTile(
          emojiSelection: emojiSelection,
          emojiChar: charList[index],
        );
      },
    );
  }
}
