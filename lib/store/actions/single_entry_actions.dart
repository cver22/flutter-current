part of 'actions.dart';

AppState _updateSingleEntryState(
  AppState appState,
  SingleEntryState update(SingleEntryState singleEntryState),
) {
  return appState.copyWith(singleEntryState: update(appState.singleEntryState));
}

class UpdateSingleEntryState implements Action {
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
        (entryState) => entryState.copyWith(
              selectedEntry: selectedEntry,
              selectedTag: selectedTag,
              tags: tags,
              logCategoryList: logCategoryList,
              savingEntry: savingEntry,
            ));
  }
}

/*SET OR SELECT ENTRY*/

class SetNewSelectedEntry implements Action {
  //sets new entry and resets all entry data not yet available
  final String logId;

  SetNewSelectedEntry({@required this.logId});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = MyEntry();
    Log log = appState.logsState.logs[logId];
    Map<String, Tag> tags = Map.from(appState.tagState.tags)..removeWhere((key, value) => value.logId != log.id);
    Map<String, Member> members = _setMembersList(log: log);

    entry = entry.copyWith(
        logId: log.id, currency: log.currency, dateTime: DateTime.now(), tagIDs: [], entryMembers: members);

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe.some(entry),
            selectedTag: Maybe.none(),
            tags: tags,
            logCategoryList: log.categories,
            savingEntry: false));
  }
}

class SelectEntry implements Action {
  //sets selected entry and resets all entry data not yet available
  final String entryId;

  SelectEntry({@required this.entryId});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = appState.entriesState.entries[entryId];
    Log log = appState.logsState.logs.values.firstWhere((element) => element.id == entry.logId);
    Map<String, Tag> tags = Map.from(appState.tagState.tags)..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> entryMembers = Map.from(entry.entryMembers);
    entryMembers.updateAll((key, value) => value.copyWith(
          payingController: TextEditingController(text: formattedAmount(value: value?.paid)),
          spendingController: TextEditingController(text: formattedAmount(value: value?.spent)),
          payingFocusNode: FocusNode(),
          spendingFocusNode: FocusNode(),
        ));

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe.some(entry.copyWith(entryMembers: entryMembers)),
            selectedTag: Maybe.none(),
            tags: tags,
            logCategoryList: log.categories,
            savingEntry: false));
  }
}

/*ADD UPDATE DELETE ENTRY SECTION*/

class AddUpdateSingleEntry implements Action {
  //submits new entry to the entries list and the clear the singleEntryState
  final MyEntry entry;
  final Log log;

  AddUpdateSingleEntry({this.entry, this.log});

  AppState updateState(AppState appState) {
    Env.store.dispatch(SingleEntryProcessing());

    if (entry.id != null &&
        entry !=
            appState.entriesState.entries.entries
                .map((e) => e.value)
                .toList()
                .firstWhere((element) => element.id == entry.id)) {
      //update entry if id is not null and thus already exists an the entry has been modified
      Env.entriesFetcher.updateEntry(entry);
    } else if (entry.id == null) {
      //save new entry using the user id to help minimize chance of duplication of entry ids in the database
      Env.entriesFetcher
          .addEntry(entry.copyWith(id: '${appState.authState.user.value.id}-${Uuid().v4()}', dateTime: DateTime.now()));
    }
    Env.store.dispatch(AddUpdateTags());

    return _updateSingleEntryState(appState, (singleEntryState) => SingleEntryState.initial());
  }
}

class DeleteSelectedEntry implements Action {
  @override
  AppState updateState(AppState appState) {
    Env.store.dispatch(SingleEntryProcessing());
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    List<MyCategory> categories = appState.singleEntryState.logCategoryList;
    Map<String, Tag> tags = appState.singleEntryState.tags;
    EntriesState updatedEntriesState = appState.entriesState;
    updatedEntriesState.entries.removeWhere((key, value) => key == entry.id);

    entry.tagIDs.forEach((tagId) {
      //updates log list of tags
      Tag tag = tags[tagId];

      //decrement use of tag for this category and log
      tag = _decrementCategoryAndLogFrequency(updatedTag: tag, categoryId: entry?.categoryId);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });

    Env.entriesFetcher.deleteEntry(entry);

    //TODO send to update all changed tags
    //Map<String, Tag> stateTags = appState.tagState.tags;

    //TODO ask Boris, is this kind of action legal, or do I need to pass the revised state back to this action?
    Env.store.dispatch(ClearEntryState());

    return _updateEntriesState(appState, (entriesState) => updatedEntriesState);
  }
}

class SingleEntryProcessing implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (singleEntryState) => singleEntryState.copyWith(savingEntry: true));
  }
}

class ClearEntryState implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (entryState) => SingleEntryState.initial());
  }
}

/*CHANGE ENTRY VALUES*/

class UpdateSelectedEntry implements Action {
  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String category;
  final String subcategory;
  final int amount;
  final String comment;
  final DateTime dateTime;

  UpdateSelectedEntry(
      {this.id,
      this.logId,
      this.currency,
      this.active,
      this.category,
      this.subcategory,
      this.amount,
      this.comment,
      this.dateTime});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(
              id: id,
              logId: logId,
              currency: currency,
              categoryId: category,
              subcategoryId: subcategory,
              amount: amount,
              comment: comment,
              dateTime: dateTime,
            ))));
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

class ChangeEntryCategories implements Action {
  final String newCategory;

  ChangeEntryCategories({@required this.newCategory});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    String oldCategoryId = entry.categoryId;

    entry.tagIDs.forEach((tagId) {
      Tag tag = tags[tagId];

      if (oldCategoryId != null) {
        //decrements only if there was a previous category
        tag = _decrementCategoryFrequency(categoryId: oldCategoryId, updatedTag: tag);
      }

      tag = _incrementCategoryFrequency(categoryId: newCategory, updatedTag: tag);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
            tags: tags,
            selectedEntry: Maybe.some(
              entry.changeCategories(category: newCategory),
            )));
  }
}

/*MEMBER ACTIONS*/

class UpdateMemberPaidAmount implements Action {
  final int paidValue;
  final EntryMember member;

  UpdateMemberPaidAmount({@required this.paidValue, @required this.member});

  AppState updateState(AppState appState) {
    print('triggered with value of: $paidValue');
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    int amount = 0;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //update amount paid by individual member
    member = member.copyWith(paid: paidValue);
    members.update(member.uid, (value) => member);

    //update total amount paid by all members
    members.forEach((key, value) {
      if (value.paid != null) {
        amount = amount + value.paid;
      }
    });

    print('the amount is: $amount');

    members = _divideSpendingEvenly(amount: amount, members: members);

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(amount: amount, entryMembers: members)),
            ));
  }
}

class UpdateMemberSpentAmount implements Action {
  //TODO need a method to distribute remaining funds amongst those spending
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
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members)),
            ));
  }
}

class ToggleMemberPaying implements Action {
  //TODO will need a UI catch to prevent there from being no payers

  final EntryMember member;

  ToggleMemberPaying({@required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

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
      member = member.copyWith(paying: !member.paying, paid: 0);
      members.update(member.uid, (value) => member);
    }

    //redistributes expense based on revision of who is paying
    members = _divideSpendingEvenly(amount: entry.amount, members: members);

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members)),
            ));
  }
}

class ToggleMemberSpending implements Action {
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
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members)),
            ));
  }
}

/*TAGS SECTION*/

class AddNewTagToEntry implements Action {
  final Tag tag;

  AddNewTagToEntry({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag addedUpdatedTag = tag; //TODO - update the editor to utilize the selectedTagState and pull from there
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;

    if (addedUpdatedTag.id == null) {
      //save new tag using the user id to help minimize chance of duplication of entry ids in the database

      addedUpdatedTag = addedUpdatedTag.copyWith(
          uid: appState.authState.user.value.id,
          id: '${Uuid().v4()}-${appState.authState.user.value.id}',
          logId: entry.logId,
          logFrequency: 1);

      entry.tagIDs.add(addedUpdatedTag.id);

      addedUpdatedTag = _incrementCategoryFrequency(updatedTag: addedUpdatedTag, categoryId: entry?.categoryId);
      print('this is the updated tag $addedUpdatedTag');

      tags.update(addedUpdatedTag.id, (value) => addedUpdatedTag, ifAbsent: () => addedUpdatedTag);
    }

    return _updateSingleEntryState(
        appState,
        (singleEntryState) =>
            singleEntryState.copyWith(selectedEntry: Maybe.some(entry), selectedTag: Maybe.none(), tags: tags));
  }
}

class AddOrRemoveEntryTag implements Action {
  final Tag tag;

  AddOrRemoveEntryTag({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag updatedTag = tag;
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

      updatedTag = _decrementCategoryAndLogFrequency(updatedTag: updatedTag, categoryId: entry?.categoryId);

      //remove the tag from the entry tag list
      entryTagIds.remove(tag.id);
    } else {
      //add tag to entry if not present

      //increment use of tag for this category
      updatedTag = _incrementCategoryAndLogFrequency(updatedTag: updatedTag, categoryId: entry?.categoryId);

      //remove the tag from the entry tag list
      entryTagIds.add(tag.id);
    }

    tags.update(updatedTag.id, (value) => updatedTag, ifAbsent: () => updatedTag);

    return _updateSingleEntryState(
        appState,
        (singleEntryState) =>
            singleEntryState.copyWith(selectedEntry: Maybe.some(entry.copyWith(tagIDs: entryTagIds)), tags: tags));
  }
}

Tag _incrementCategoryFrequency({@required String categoryId, @required Tag updatedTag}) {
  if (categoryId != null) {
    Map<String, int> tagCategoryFrequency = Map.from(updatedTag.tagCategoryFrequency);

    //adds frequency to tag for the category if present, adds it otherwise
    tagCategoryFrequency.update(categoryId, (value) => value + 1, ifAbsent: () => 1);
    updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);
  }
  return updatedTag;
}

Tag _incrementCategoryAndLogFrequency({@required Tag updatedTag, @required String categoryId}) {
  //increment use of tag for this category

  updatedTag = _incrementCategoryFrequency(categoryId: categoryId, updatedTag: updatedTag);

  //increment use of tag for this log
  updatedTag = updatedTag.incrementTagLogFrequency();

  return updatedTag;
}

Tag _decrementCategoryFrequency({@required String categoryId, @required Tag updatedTag}) {
  if (categoryId != null) {
    Map<String, int> tagCategoryFrequency = Map.from(updatedTag.tagCategoryFrequency);

    //subtracts frequency to tag for the category if present, adds it otherwise
    tagCategoryFrequency.update(categoryId, (value) => value - 1, ifAbsent: () => 0);
    tagCategoryFrequency.removeWhere(
        (key, value) => value < 1); //removes category frequencies where the tags is no longer used by any entries

    updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);
  }
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

  remainder = amount.remainder(membersSpending);

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

Map<String, EntryMember> _setMembersList({@required Log log}) {
  //adds the log members to the entry member list when creating a new entry of changing logs

  Map<String, EntryMember> members = {};

  log.logMembers.forEach((key, value) {
    members.putIfAbsent(
        key,
        () => EntryMember(
              uid: value.uid,
              paying: value.role == OWNER ? true : false,
              payingController: TextEditingController(),
              spendingController: TextEditingController(),
              payingFocusNode: FocusNode(),
              spendingFocusNode: FocusNode(),
            ));
  });

  return members;
}
