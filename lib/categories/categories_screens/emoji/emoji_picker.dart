import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';

import '../../../utils/db_consts.dart';
import 'emoji_grid.dart';

class EmojiPicker extends StatelessWidget {
  final Function(String) emojiSelection;

  const EmojiPicker({@required this.emojiSelection});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
      child: DefaultTabController(
        length: 8,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ELEVATED_BUTTON_CIRCULAR_RADIUS),
                topRight: Radius.circular(ELEVATED_BUTTON_CIRCULAR_RADIUS),
              ),
            ),
            //TODO handle back button
            automaticallyImplyLeading: false,
            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TabBar(
                  labelPadding: EdgeInsets.all(0),
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
              EmojiGrid(
                  emojiGroup: EmojiGroup.peopleBody,
                  emojiSelection: emojiSelection),
              EmojiGrid(
                  emojiGroup: EmojiGroup.animalsNature,
                  emojiSelection: emojiSelection),
              EmojiGrid(
                  emojiGroup: EmojiGroup.foodDrink,
                  emojiSelection: emojiSelection),
              EmojiGrid(
                  emojiGroup: EmojiGroup.objects,
                  emojiSelection: emojiSelection),
              EmojiGrid(
                  emojiGroup: EmojiGroup.travelPlaces,
                  emojiSelection: emojiSelection),
              EmojiGrid(
                  emojiGroup: EmojiGroup.activities,
                  emojiSelection: emojiSelection),
              EmojiGrid(
                  emojiGroup: EmojiGroup.symbols,
                  emojiSelection: emojiSelection),
              EmojiGrid(
                  emojiGroup: EmojiGroup.flags, emojiSelection: emojiSelection),
            ],
          ),
        ),
      ),
    );
  }
}
