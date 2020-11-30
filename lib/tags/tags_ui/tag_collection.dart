import 'package:expenses/entry/entry_model/entry_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';

import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_chip.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class TagCollection extends StatelessWidget {
  final List<Tag> tags;
  final MyEntry entry;
  final EntryState entryState;

  final String collectionName;
  final TagCollectionType tagCollectionType;

  const TagCollection(
      {Key key,
      @required this.tags,
      @required this.entry,
      @required this.collectionName,
      @required this.tagCollectionType, @required this.entryState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> tagChips = [];
    List<String> entryTagIds = [];
    List<Tag>  logTagList = entryState.logTagList;

    bool tagAlreadyListed = false;


    tags.forEach((thisTag) {
      tagChips.add(TagChip(
        name: thisTag.name,
        onPressed: () => {
          entryTagIds = entry.tagIDs,
          if (tagCollectionType == TagCollectionType.entry)
            {
              logTagList.removeWhere((element) => element.id == thisTag.id),
              logTagList.add(thisTag.decrement(tag: thisTag)),


              entryTagIds.remove(thisTag.id),
              Env.store.dispatch(UpdateEntryState(selectedEntry: Maybe.some(entry.copyWith(tagIDs: entryTagIds)), logTagList: logTagList))

            }
          else
            {
              entryTagIds.forEach((element) {
                if (element == thisTag.id) {
                  tagAlreadyListed = true;
                }
              }),
              if (!tagAlreadyListed)
                {
                  //adds tag to the entry list if its not already on there
                  logTagList.removeWhere((element) => element.id == thisTag.id),
                  logTagList.add(thisTag.increment(tag: thisTag)),

                  entryTagIds.add(thisTag.id),
                  Env.store.dispatch(UpdateEntryState(selectedEntry: Maybe.some(entry.copyWith(tagIDs: entryTagIds)), logTagList: logTagList))
                }
              else
                {
                  tagAlreadyListed = false,
                }
            }
        },
      ));
    });
    return Column(
      children: [
        Text(collectionName),
        Wrap(
          spacing: 5.0,
          runSpacing: 3.0,
          children: tagChips,
        ),
      ],
    );
  }

//TODO maybe filter by what is typed
//TODO use tag state to pass onEdit to the selector

}
