part of 'my_actions.dart';

AppState _updateSingleEntryState(AppState appState,
    SingleEntryState update(SingleEntryState singleEntryState),) {
  return appState.copyWith(singleEntryState: update(appState.singleEntryState));
}

class UpdateSingleEntryState implements MyAction {
  final Maybe<MyEntry> selectedEntry;
  final Maybe<Tag> selectedTag;
  final Map<String, Tag> tags;
  final List<MyCategory> logCategoryList;
  final bool savingEntry;

  UpdateSingleEntryState({this.selectedEntry, this.selectedTag, this.tags, this.logCategoryList, this.savingEntry});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
              selectedEntry: selectedEntry,
              selectedTag: selectedTag,
              tags: tags,
              categories: logCategoryList,
              processing: savingEntry,
            ));
  }
}

/*SET OR SELECT ENTRY*/

class SetNewSelectedEntry implements MyAction {
  //sets new entry and resets all entry data not yet available
  final String logId;
  final String memberId;

  SetNewSelectedEntry({this.logId, this.memberId});

  @override
  AppState updateState(AppState appState) {
    //TODO can probably abstract away to either settings model or to settings actions, i think model would be better, only update if needed

    MyEntry entry = MyEntry();
    //if a log is not passed to the action it is assumed to have been triggered from the FAB and creates and entry for the default log

    Log log = appState.logsState
        .logs[logId ?? appState.settingsState.settings?.value?.defaultLogId ?? appState.logsState.logs.keys.first];
    Map<String, Tag> tags = Map.from(appState.tagState.tags)
      ..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> members = _setMembersList(log: log, memberId: memberId);

    entry = entry.copyWith(
        logId: log.id,
        currency: log.currency,
        dateTime: DateTime.now(),
        tagIDs: [],
        entryMembers: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
                selectedEntry: Maybe.some(entry),
                selectedTag: Maybe.some(Tag()),
                tags: tags,
                categories: List.from(log.categories),
                subcategories: List.from(log.subcategories),
                processing: false,
            commentFocusNode: FocusNode(),
            tagFocusNode: FocusNode(),));
  }
}

class SelectEntry implements MyAction {
  //sets selected entry and resets all entry data not yet available
  final String entryId;

  SelectEntry({@required this.entryId});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = appState.entriesState.entries[entryId];
    Log log = appState.logsState.logs.values.firstWhere((element) => element.id == entry.logId);
    Map<String, Tag> tags = Map.from(appState.tagState.tags)
      ..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> entryMembers = Map.from(entry.entryMembers);
    entryMembers.updateAll((key, value) =>
        value.copyWith(
          payingController: TextEditingController(text: formattedAmount(value: value?.paid)),
          spendingController: TextEditingController(text: formattedAmount(value: value?.spent)),
          payingFocusNode: FocusNode(),
          spendingFocusNode: FocusNode(),
        ));

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
                selectedEntry: Maybe.some(entry.copyWith(entryMembers: entryMembers)),
                selectedTag: Maybe.some(Tag()),
                tags: tags,
                categories: List.from(log.categories),
                subcategories: List.from(log.subcategories),
                processing: false,
              commentFocusNode: FocusNode(),
              tagFocusNode: FocusNode(),
            ));
  }
}

/*ADD UPDATE DELETE ENTRY SECTION*/

class SingleEntryProcessing implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (singleEntryState) => singleEntryState.copyWith(processing: true));
  }
}

class ClearEntryState implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (entryState) => SingleEntryState.initial());
  }
}

/*CHANGE ENTRY VALUES*/

class UpdateEntryCurrency implements MyAction {
  final String currency;

  UpdateEntryCurrency({@required this.currency});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(currency: currency)),
                userUpdated: true));
  }
}

class UpdateEntryComment implements MyAction {
  final String comment;

  UpdateEntryComment({@required this.comment});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(comment: comment)),
                userUpdated: true));
  }
}

class UpdateEntryDateTime implements MyAction {
  final DateTime dateTime;

  UpdateEntryDateTime({this.dateTime});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(dateTime: dateTime)),
                userUpdated: true));
  }
}

class UpdateEntrySubcategory implements MyAction {
  final String subcategory;

  UpdateEntrySubcategory({this.subcategory});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(subcategoryId: subcategory)),
                userUpdated: true));
  }
}

/*class ChangeEntryLog implements Action {
  final Log log;

  ChangeEntryLog({@required this.log});

  @override
  AppState updateState(AppState appState) {
    if (log.id == appState.singleEntryState.selectedEntry.value.logId) {
      return _updateSingleEntryState(appState, (singleEntryState) => singleEntryState);
    } else {
      Map<String, Tag> tags = Map.from(appState.tagState.tags)
        ..removeWhere((key, value) => value.logId != log.id); //log changes tags change
      Map<String, Member> members = _setMembersList(log: log); //log changes members change
      //TODO changing the entry log is more complicated than this, first you actually need to update the log it came from, then the log its going to

      return _updateSingleEntryState(
          appState,
          (singleEntryState) => singleEntryState.copyWith(
              tags: tags,
              selectedTag: Maybe.none(),
              logCategoryList: log.categories,
              selectedEntry: Maybe.some(
                singleEntryState.selectedEntry.value
                    .changeLog(log: log)
                    .copyWith(tagIDs: List<String>(), entryMembers: members),
              )));
    }
  }
}*/

class UpdateEntryCategory implements MyAction {
  final String newCategory;

  UpdateEntryCategory({@required this.newCategory});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    String oldCategoryId = entry.categoryId;

    entry.tagIDs.forEach((tagId) {
      Tag tag = tags[tagId];

      //uses NO_CATEGORY for increment and decrement default as the actions utilize NO_CATEGORY until it is confirmed by the user
      tag = _decrementCategoryFrequency(categoryId: oldCategoryId ?? NO_CATEGORY, updatedTag: tag);

      tag = _incrementCategoryFrequency(categoryId: newCategory ?? NO_CATEGORY, updatedTag: tag);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              tags: tags,
              selectedEntry: Maybe.some(entry.changeCategories(category: newCategory ?? NO_CATEGORY)),
              userUpdated: true,
            ));
  }
}

class ReorderCategoriesFromEntryScreen implements MyAction {
  final int newIndex;
  final int oldIndex;

  ReorderCategoriesFromEntryScreen({@required this.newIndex, @required this.oldIndex});

  AppState updateState(AppState appState) {
    List<MyCategory> categories = List.from(appState.singleEntryState.categories);
    int categoryNewIndex = newIndex;

    if (newIndex > categories.length) categoryNewIndex = categories.length;
    if (oldIndex < newIndex) categoryNewIndex--;

    MyCategory category = categories[oldIndex];
    categories.remove(category);
    categories.insert(categoryNewIndex, category);

    return _updateSingleEntryState(
      appState,
          (singleEntryState) => singleEntryState.copyWith(categories: categories, userUpdated: true),
    );
  }
}

class ReorderSubcategoriesFromEntryScreen implements MyAction {
  final List<MyCategory> reorderedSubcategories;
  final int newIndex;
  final int oldIndex;

  ReorderSubcategoriesFromEntryScreen(
      {@required this.newIndex, @required this.oldIndex, @required this.reorderedSubcategories});

  AppState updateState(AppState appState) {
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    int subcategoryNexIndex = newIndex;

    if (subcategories.length > 1) {
      if (newIndex > reorderedSubcategories.length) subcategoryNexIndex = reorderedSubcategories.length;
      if (oldIndex < subcategoryNexIndex) subcategoryNexIndex--;

      MyCategory category = reorderedSubcategories[oldIndex];
      reorderedSubcategories.remove(category);
      reorderedSubcategories.insert(newIndex, category);

      reorderedSubcategories.forEach((reordedSub) {
        subcategories.removeWhere((sub) => reordedSub.id == sub.id);
      });
      reorderedSubcategories.forEach((subcategory) {
        subcategories.add(subcategory);
      });
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) => singleEntryState.copyWith(subcategories: subcategories, userUpdated: true),
    );
  }
}

class AddEditCategoryFromEntryScreen implements MyAction {
  final MyCategory category;

  AddEditCategoryFromEntryScreen({@required this.category});

  AppState updateState(AppState appState) {
    List<MyCategory> categories = List.from(appState.singleEntryState.categories);
    if (category.id == null) {
      categories.add(category.copyWith(id: Uuid().v4()));
    } else {
      categories[categories.indexWhere((entry) => entry.id == category.id)] = category;
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) => singleEntryState.copyWith(categories: categories, userUpdated: true),
    );
  }
}

class DeleteCategoryFromEntryScreen implements MyAction {
  final MyCategory category;

  DeleteCategoryFromEntryScreen({@required this.category});

  AppState updateState(AppState appState) {
    List<MyCategory> categories = List.from(appState.singleEntryState.categories);
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    bool canDeleteCategory = _canDeleteCategory(id: category.id);

    //remove category and its subcategories if the category is not "no category"
    if (canDeleteCategory) {
      categories.removeWhere((e) => e.id == category.id);
      subcategories.removeWhere((e) => e.parentCategoryId == category.id);
    }
    if (category.id == entry.categoryId) {
      //if we deleted the category used by the entry, reset the entry to no category or subcategory
      entry = MyEntry(
        id: entry.id,
        logId: entry.logId,
        currency: entry.currency,
        amount: entry.amount,
        comment: entry.comment,
        dateTime: entry.dateTime,
        tagIDs: entry.tagIDs,
        entryMembers: entry.entryMembers,
      );
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) =>
          singleEntryState.copyWith(
              categories: categories,
              subcategories: subcategories,
              selectedEntry: Maybe.some(entry),
              userUpdated: false),
    );
  }
}

class AddEditSubcategoryFromEntryScreen implements MyAction {
  final MyCategory subcategory;

  AddEditSubcategoryFromEntryScreen({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    String previousParentId = entry.categoryId;

    if (subcategory.id == null) {
      //add new subcategory
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    } else {
      //edit subcategory
      subcategories[subcategories.indexWhere((entry) => entry.id == subcategory.id)] = subcategory;

      //if the parent category of the subcategory was changed and thus the entry category changed, update the tag frequency
      if (previousParentId != subcategory.parentCategoryId && entry.subcategoryId == subcategory.id) {
        entry.tagIDs.forEach((tagId) {
          Tag tag = tags[tagId];

          tag = _decrementCategoryFrequency(categoryId: previousParentId, updatedTag: tag);

          tag = _incrementCategoryFrequency(categoryId: subcategory.parentCategoryId, updatedTag: tag);

          tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
        });
        entry = entry.copyWith(categoryId: subcategory.parentCategoryId);
      }
    }

    //update the subcategory as well as the category if the parent has changed
    return _updateSingleEntryState(
      appState,
          (singleEntryState) =>
          singleEntryState.copyWith(
              subcategories: subcategories, tags: tags, selectedEntry: Maybe.some(entry), userUpdated: true),
    );
  }
}

class DeleteSubcategoryFromEntryScreen implements MyAction {
  final MyCategory subcategory;

  DeleteSubcategoryFromEntryScreen({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    bool canDeleteSubcategory = _canDeleteSubcategory(subcategory: subcategory);

    if (canDeleteSubcategory) {
      subcategories.removeWhere((e) => e.id == subcategory.id);
      if (subcategory.id == entry.subcategoryId) {
        //TODO this should auto select the "other" subcategory
        //entry = entry.copyWith(subcategoryId: NO_SUBCATEGORY);
      }
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) =>
          singleEntryState.copyWith(subcategories: subcategories, selectedEntry: Maybe.some(entry), userUpdated: true),
    );
  }
}

//TODO this should be combined with ClearEntryState()
class UpdateLogCategoriesSubcategoriesOnEntryScreenClose implements MyAction {
  @override
  AppState updateState(AppState appState) {
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    logs = _updateLogCategoriesSubcategoriesFromEntry(
        appState: appState, logId: appState.singleEntryState.selectedEntry.value.logId, logs: logs);

    return _updateLogState(appState, (logsState) => logsState.copyWith(logs: logs));
  }
}

/*MEMBER ACTIONS*/

class UpdateMemberPaidAmount implements MyAction {
  final int paidValue;
  final EntryMember member;

  UpdateMemberPaidAmount({@required this.paidValue, @required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    int amount = 0;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //update amount paid by individual member
    member = member.copyWith(paid: paidValue);
    members.update(member.uid, (value) => member);

    //update total amount paid by all members
    members.forEach((key, value) {
      if (value.paid != null && value.paying) {
        amount = amount + value.paid;
      }
    });

    members = _divideSpendingEvenly(amount: amount, members: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(amount: amount, entryMembers: members)),
              userUpdated: true,
            ));
  }
}

class UpdateMemberSpentAmount implements MyAction {
  final int spentValue;
  final EntryMember member;

  UpdateMemberSpentAmount({@required this.spentValue, @required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //update amount spent by individual member
    member = member.copyWith(spent: spentValue);
    members.update(member.uid, (value) => member);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members)),
              userUpdated: true,
            ));
  }
}

class ToggleMemberPaying implements MyAction {
  final EntryMember member;

  ToggleMemberPaying({@required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;
    int amount = 0;

    //count number of members paying
    int membersPaying = 0;
    members.forEach((key, value) {
      if (value.paying == true) {
        membersPaying += 1;
      }
    });

    //if the selected payer is the last, they cannot be removed
    if (membersPaying > 1 || member.paying == false) {
      //toggles member paying or not
      FocusNode payingFocusNode = member.payingFocusNode;

      //if member is now paying, focus on their paid amount variable
      if (member.paying == false) {
        payingFocusNode.requestFocus();
      } else if (payingFocusNode.hasFocus) {
        payingFocusNode.unfocus();
      }

      member = member.copyWith(paying: !member.paying, payingFocusNode: payingFocusNode);

      members.update(member.uid, (value) => member);
    }

    members.forEach((key, value) {
      if (value.paid != null && value.paying) {
        amount = amount + value.paid;
      }
    });

    //redistributes expense based on revision of who is paying
    members = _divideSpendingEvenly(amount: amount, members: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members, amount: amount)),
              userUpdated: true,
            ));
  }
}

class ToggleMemberSpending implements MyAction {
  final EntryMember member;

  ToggleMemberSpending({@required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //toggles member spending or not
    int membersSpending = 0;
    members.forEach((key, value) {
      if (value.spending == true) {
        membersSpending += 1;
      }
    });

    //cannot uncheck member if they are the last spending
    if (membersSpending > 1 || member.spending == false) {
      member = member.copyWith(spending: !member.spending, spent: 0);
      members.update(member.uid, (value) => member);
    }

    //redistributes expense based on revision of who is paying
    members = _divideSpendingEvenly(amount: entry.amount, members: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members)),
              userUpdated: true,
            ));
  }
}

/*TAGS SECTION*/

class AddUpdateTagFromEntryScreen implements MyAction {
  final Tag tag;

  AddUpdateTagFromEntryScreen({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag addedUpdatedTag = tag;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Tag existingTag;

    for (Tag value in tags.values.toList()) {
      if (value.name.toLowerCase() == tag.name.toLowerCase()) {
        existingTag = value;
        break;
      }
    }

    if (addedUpdatedTag.id == null) {
      if (existingTag == null) {
        //save new tag using the user id to help minimize chance of duplication of entry ids in the database
        addedUpdatedTag = addedUpdatedTag.copyWith(
          id: '${Uuid().v4()}-${appState.authState.user.value.id}',
          logId: entry.logId,
          tagLogFrequency: 1,
          memberList: entry.entryMembers.keys.toList(),
        );
      } else {
        //the tag already exists in the log, add to the entry and increment the log frequency
        addedUpdatedTag = existingTag.incrementTagLogFrequency();
      }

      entry.tagIDs.add(addedUpdatedTag.id);

      addedUpdatedTag =
          _incrementCategoryFrequency(updatedTag: addedUpdatedTag, categoryId: entry.categoryId ?? NO_CATEGORY);
      print('tag: $addedUpdatedTag');
    }

    //updates existing tag or add it
    tags.update(addedUpdatedTag.id, (value) => addedUpdatedTag, ifAbsent: () => addedUpdatedTag);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
                selectedEntry: Maybe.some(entry), selectedTag: Maybe.some(Tag()), tags: tags, userUpdated: true));
  }
}

class SelectDeselectEntryTag implements MyAction {
  final Tag tag;

  SelectDeselectEntryTag({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag selectedDeselectedTag = tag;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    List<String> entryTagIds = entry.tagIDs;
    bool entryHasTag = false;

    //determines if the tag is in the entry or in another list
    entryTagIds.forEach((element) {
      if (element == tag.id) {
        entryHasTag = true;
      }
    });

    if (entryHasTag) {
      //remove tag from entry if present

      selectedDeselectedTag = _decrementCategoryAndLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry?.categoryId ?? NO_CATEGORY);

      //remove the tag from the entry tag list
      entryTagIds.remove(tag.id);
    } else {
      //add tag to entry if not present

      //increment use of tag for this category
      selectedDeselectedTag = _incrementCategoryAndLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry?.categoryId ?? NO_CATEGORY);

      //remove the tag from the entry tag list
      entryTagIds.add(tag.id);
    }

    tags.update(selectedDeselectedTag.id, (value) => selectedDeselectedTag, ifAbsent: () => selectedDeselectedTag);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
                selectedEntry: Maybe.some(entry.copyWith(tagIDs: entryTagIds)), tags: tags, userUpdated: true));
  }
}

class EntryNextFocus implements MyAction {
  @override
  AppState updateState(AppState appState) {
    My Entry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> memberMap = Map.from(entry.entryMembers);
    List<EntryMember> memberList = memberMap.values.toList();
    int memberFocusIndex;
    bool membersHaveFocus = false;
    FocusNode commentFocusNode = appState.singleEntryState.commentFocusNode.value;
    FocusNode tagFocusNode = appState.singleEntryState.tagFocusNode.value;

    for (int i = 0; i < memberList.length; i++) {
      if (memberList[i].payingFocusNode.hasFocus) {
        //remove focus from current focused member
        memberFocusIndex = i;
        FocusNode payingFocusNode = memberList[i].payingFocusNode;
        payingFocusNode.unfocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(payingFocusNode: payingFocusNode));
      } else if (memberFocusIndex != null && i > memberFocusIndex && memberList[i].paying == true) {
        //focus on next paying member if there is one
        FocusNode payingFocusNode = memberList[i].payingFocusNode;
        payingFocusNode.requestFocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(payingFocusNode: payingFocusNode));
        membersHaveFocus = true;
        break;
      }
    }

    if (!membersHaveFocus) {
      if (!commentFocusNode.hasFocus) {
        commentFocusNode.requestFocus();
      } else {
        commentFocusNode.unfocus();
        tagFocusNode.requestFocus();
      }
    }


    return _updateSingleEntryState(appState, (singleEntryState) =>
        singleEntryState.copyWith(selectedEntry: Maybe.some(entry.copyWith(entryMembers: memberMap)),
          commentFocusNode: Maybe.some(commentFocusNode),
          tagFocusNode: Maybe.some(tagFocusNode),));
  }
}


Tag _incrementCategoryFrequency({@required String categoryId, @required Tag updatedTag}) {
  Map<String, int> tagCategoryFrequency = Map.from(updatedTag.tagCategoryFrequency);

  //adds frequency to tag for the category if present, adds it otherwise
  tagCategoryFrequency.update(categoryId, (value) => value + 1, ifAbsent: () => 1);
  updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);

  return updatedTag;
}

Tag _incrementCategoryAndLogFrequency({@required Tag updatedTag, String categoryId}) {
  //increment use of tag for this category

  updatedTag = _incrementCategoryFrequency(categoryId: categoryId, updatedTag: updatedTag);

  //increment use of tag for this log
  updatedTag = updatedTag.incrementTagLogFrequency();

  return updatedTag;
}

Tag _decrementCategoryFrequency({@required String categoryId, @required Tag updatedTag}) {
  Map<String, int> tagCategoryFrequency = Map.from(updatedTag.tagCategoryFrequency);

  //subtracts frequency to tag for the category if present, adds it otherwise
  tagCategoryFrequency.update(categoryId, (value) => value - 1, ifAbsent: () => 0);
  tagCategoryFrequency.removeWhere(
          (key, value) => value < 1); //removes category frequencies where the tags is no longer used by any entries

  updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);

  return updatedTag;
}

Tag _decrementCategoryAndLogFrequency({@required Tag updatedTag, @required String categoryId}) {
  //decrement use of tag for this category

  updatedTag = _decrementCategoryFrequency(categoryId: categoryId, updatedTag: updatedTag);

  //decrement use of tag for this log
  updatedTag = updatedTag.decrementTagLogFrequency();

  return updatedTag;
}

Map<String, EntryMember> _divideSpendingEvenly({@required int amount, @required Map<String, EntryMember> members}) {
  Map<String, EntryMember> entryMembers = Map.from(members);
  int membersSpending = 0;
  int remainder = 0;

  //if members are spending, add the to the divisor
  entryMembers.forEach((key, value) {
    if (value.spending == true) {
      membersSpending += 1;
    }
  });

  if (amount != null) {
    remainder = amount.remainder(membersSpending);
  }

  //TODO need to handle the remainder, could possibly do this by dividing the initial value by 3, then subtracting the value each time until the last member is reached
  //re-adjust who spent based on the new total amount
  entryMembers.forEach((key, value) {
    int memberSpentAmount = 0;
    if (value.spending == true && amount != null && amount != 0) {
      memberSpentAmount = (amount / membersSpending).truncate();

      if (remainder > 0) {
        memberSpentAmount += 1;
        remainder--;
      }
    }

    value.spendingController.value = TextEditingValue(text: formattedAmount(value: memberSpentAmount));
    entryMembers.update(key, (value) => value.copyWith(spent: memberSpentAmount));
  });

  return entryMembers;
}

Map<String, EntryMember> _setMembersList({@required Log log, @required String memberId}) {
  //adds the log members to the entry member list when creating a new entry of changing logs

  Map<String, EntryMember> members = {};

  log.logMembers.forEach((key, value) {
    members.putIfAbsent(
        key,
            () =>
            EntryMember(
              uid: value.uid,
              order: value.order,
              paying: value.role == OWNER ? true : false,
              payingController: TextEditingController(),
              spendingController: TextEditingController(),
              payingFocusNode: FocusNode(),
              spendingFocusNode: FocusNode(),
            ));
  });

  //sets the selected user as paying unless the action is triggered from the FAB
  members.updateAll((key, value) => value.copyWith(paying: key == memberId ? true : false));

  return members;
}
