import 'package:emojis/emoji.dart';
import 'package:expenses/categories/categories_screens/emoji/emoji_grid.dart';
import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {
  final Function(String) emojiSelection;

  const EmojiPicker({@required this.emojiSelection});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 8,
      child: Scaffold(
        resizeToAvoidBottomPadding: true,
        appBar: AppBar(
          //TODO handle back button
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TabBar(
                tabs: [
                  Tab(child: Icon(Icons.emoji_people_outlined)),
                  Tab(child: Icon(Icons.emoji_nature_outlined)),
                  Tab(child: Icon(Icons.emoji_food_beverage_outlined)),
                  Tab(child: Icon(Icons.emoji_objects_outlined)),
                  Tab(child: Icon(Icons.emoji_transportation_outlined)),
                  Tab(child: Icon(Icons.emoji_events_outlined)),
                  Tab(child: Icon(Icons.emoji_symbols_outlined)),
                  Tab(child: Icon(Icons.emoji_flags_outlined)),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EmojiGrid(emojiGroup: EmojiGroup.peopleBody, emojiSelection: emojiSelection),
            EmojiGrid(emojiGroup: EmojiGroup.animalsNature, emojiSelection: emojiSelection),
            EmojiGrid(emojiGroup: EmojiGroup.foodDrink, emojiSelection: emojiSelection),
            EmojiGrid(emojiGroup: EmojiGroup.objects, emojiSelection: emojiSelection),
            EmojiGrid(emojiGroup: EmojiGroup.travelPlaces, emojiSelection: emojiSelection),
            EmojiGrid(emojiGroup: EmojiGroup.activities, emojiSelection: emojiSelection),
            EmojiGrid(emojiGroup: EmojiGroup.symbols, emojiSelection: emojiSelection),
            EmojiGrid(emojiGroup: EmojiGroup.flags, emojiSelection: emojiSelection),
          ],
        ),
      ),
    );
  }
}
