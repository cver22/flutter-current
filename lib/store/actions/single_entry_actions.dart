import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/app/models/app_state.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

AppState _updateSingleEntryState(
  AppState appState,
  SingleEntryState update(SingleEntryState singleEntryState),
) {
  return appState.copyWith(singleEntryState: update(appState.singleEntryState));
}

class UpdateSingleEntryState implements AppAction {
  final Maybe<MyEntry> selectedEntry;
  final Maybe<Tag> selectedTag;
  final Map<String, Tag> tags;
  final List<AppCategory> logCategoryList;
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
              categories: logCategoryList,
              processing: savingEntry,
            ));
  }
}

/*SET OR SELECT ENTRY*/

class SetNewSelectedEntry implements AppAction {
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
    Map<String, Tag> tags = Map.from(appState.tagState.tags)..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> members =
        _setMembersList(log: log, memberId: memberId, userId: appState.authState.user.value.id);

    entry = entry.copyWith(
        logId: log.id, currency: log.currency, dateTime: DateTime.now(), tagIDs: [], entryMembers: members);

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry),
              selectedTag: Maybe.some(Tag()),
              tags: tags,
              categories: List.from(log.categories),
              subcategories: List.from(log.subcategories),
              processing: false,
              commentFocusNode: Maybe.some(FocusNode()),
              tagFocusNode: Maybe.some(FocusNode()),
            ));
  }
}

class SelectEntry implements AppAction {
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
              selectedTag: Maybe.some(Tag()),
              tags: tags,
              categories: List.from(log.categories),
              subcategories: List.from(log.subcategories),
              processing: false,
              commentFocusNode: Maybe.some(FocusNode()),
              tagFocusNode: Maybe.some(FocusNode()),
            ));
  }
}

/*ADD UPDATE DELETE ENTRY SECTION*/

class SingleEntryProcessing implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (singleEntryState) => singleEntryState.copyWith(processing: true));
  }
}

class ClearEntryState implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (entryState) => SingleEntryState.initial());
  }
}

/*CHANGE ENTRY VALUES*/

class UpdateEntryCurrency implements AppAction {
  final String currency;

  UpdateEntryCurrency({@required this.currency});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(currency: currency)), userUpdated: true));
  }
}

class UpdateEntryComment implements AppAction {
  final String comment;

  UpdateEntryComment({@required this.comment});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(comment: comment)), userUpdated: true));
  }
}

class UpdateEntryDateTime implements AppAction {
  final DateTime dateTime;

  UpdateEntryDateTime({this.dateTime});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(dateTime: dateTime)), userUpdated: true));
  }
}

class UpdateEntrySubcategory implements AppAction {
  final String subcategory;

  UpdateEntrySubcategory({this.subcategory});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
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

class UpdateEntryCategory implements AppAction {
  final String newCategory;

  UpdateEntryCategory({@required this.newCategory});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    String oldCategoryId = entry.categoryId;

    if (entry.tagIDs.length > 0) {
      entry.tagIDs.forEach((tagId) {
        Tag tag = tags[tagId];

        //uses NO_CATEGORY for increment and decrement default as the actions utilize NO_CATEGORY until it is confirmed by the user
        tag = _decrementCategoryFrequency(categoryId: oldCategoryId ?? NO_CATEGORY, updatedTag: tag);

        tag = _incrementCategoryFrequency(categoryId: newCategory ?? NO_CATEGORY, updatedTag: tag);

        tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
      });
    }
    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
              tags: tags,
              selectedEntry: Maybe.some(entry.changeCategories(category: newCategory ?? NO_CATEGORY)),
              userUpdated: true,
            ));
  }
}

class ReorderCategoriesFromEntryScreen implements AppAction {
  final int newIndex;
  final int oldIndex;

  ReorderCategoriesFromEntryScreen({@required this.newIndex, @required this.oldIndex});

  AppState updateState(AppState appState) {
    List<AppCategory> categories = List.from(appState.singleEntryState.categories);
    int categoryNewIndex = newIndex;

    if (newIndex > categories.length) categoryNewIndex = categories.length;
    if (oldIndex < newIndex) categoryNewIndex--;

    AppCategory category = categories[oldIndex];
    categories.remove(category);
    categories.insert(categoryNewIndex, category);

    return _updateSingleEntryState(
      appState,
      (singleEntryState) => singleEntryState.copyWith(categories: categories, userUpdated: true),
    );
  }
}

class ReorderSubcategoriesFromEntryScreen implements AppAction {
  final List<AppCategory> reorderedSubcategories;
  final int newIndex;
  final int oldIndex;

  ReorderSubcategoriesFromEntryScreen(
      {@required this.newIndex, @required this.oldIndex, @required this.reorderedSubcategories});

  AppState updateState(AppState appState) {
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    int subcategoryNexIndex = newIndex;

    if (subcategories.length > 1) {
      if (newIndex > reorderedSubcategories.length) subcategoryNexIndex = reorderedSubcategories.length;
      if (oldIndex < subcategoryNexIndex) subcategoryNexIndex--;

      AppCategory category = reorderedSubcategories[oldIndex];
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

class AddEditCategoryFromEntryScreen implements AppAction {
  final AppCategory category;

  AddEditCategoryFromEntryScreen({@required this.category});

  AppState updateState(AppState appState) {
    List<AppCategory> categories = List.from(appState.singleEntryState.categories);
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

class DeleteCategoryFromEntryScreen implements AppAction {
  final AppCategory category;

  DeleteCategoryFromEntryScreen({@required this.category});

  AppState updateState(AppState appState) {
    List<AppCategory> categories = List.from(appState.singleEntryState.categories);
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    bool _canDeleteCategory = canDeleteCategory(id: category.id);

    //remove category and its subcategories if the category is not "no category"
    if (_canDeleteCategory) {
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
      (singleEntryState) => singleEntryState.copyWith(
          categories: categories, subcategories: subcategories, selectedEntry: Maybe.some(entry), userUpdated: false),
    );
  }
}

class AddEditSubcategoryFromEntryScreen implements AppAction {
  final AppCategory subcategory;

  AddEditSubcategoryFromEntryScreen({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
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
      (singleEntryState) => singleEntryState.copyWith(
          subcategories: subcategories, tags: tags, selectedEntry: Maybe.some(entry), userUpdated: true),
    );
  }
}

class DeleteSubcategoryFromEntryScreen implements AppAction {
  final AppCategory subcategory;

  DeleteSubcategoryFromEntryScreen({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    bool _canDeleteSubcategory = canDeleteSubcategory(subcategory: subcategory);

    if (_canDeleteSubcategory) {
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

/*MEMBER ACTIONS*/

class UpdateMemberPaidAmount implements AppAction {
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
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(amount: amount, entryMembers: members)),
              userUpdated: true,
            ));
  }
}

class UpdateMemberSpentAmount implements AppAction {
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
              userUpdated: true,
            ));
  }
}

class ToggleMemberPaying implements AppAction {
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
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members, amount: amount)),
              userUpdated: true,
            ));
  }
}

class ToggleMemberSpending implements AppAction {
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
              userUpdated: true,
            ));
  }
}

/*TAGS SECTION*/

class AddUpdateTagFromEntryScreen implements AppAction {
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
        (singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe.some(entry), selectedTag: Maybe.some(Tag()), tags: tags, userUpdated: true));
  }
}

class SelectDeselectEntryTag implements AppAction {
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

      selectedDeselectedTag = decrementCategoryAndLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry?.categoryId ?? NO_CATEGORY);

      //remove the tag from the entry tag list
      entryTagIds.remove(tag.id);
    } else {
      //add tag to entry if not present

      //increment use of tag for this category
      selectedDeselectedTag = incrementCategoryAndLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry?.categoryId ?? NO_CATEGORY);

      //remove the tag from the entry tag list
      entryTagIds.add(tag.id);
    }

    tags.update(selectedDeselectedTag.id, (value) => selectedDeselectedTag, ifAbsent: () => selectedDeselectedTag);

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe.some(entry.copyWith(tagIDs: entryTagIds)), tags: tags, userUpdated: true));
  }
}

class EntryMemberFocus implements AppAction {
  final String memberId;
  final PaidOrSpent paidOrSpent;

  //TODO this does not work

  EntryMemberFocus({@required this.memberId, @required this.paidOrSpent});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> memberMap = Map.from(entry.entryMembers);
    EntryMember member = memberMap[memberId];
    FocusNode focusNode;

    if (paidOrSpent == PaidOrSpent.paid) {
      focusNode = member.payingFocusNode;
      focusNode.requestFocus();
      member = member.copyWith(payingFocusNode: focusNode);
      print(member.payingFocusNode.hasFocus);
    } else if (paidOrSpent == PaidOrSpent.spent) {
      focusNode = member.spendingFocusNode;
      focusNode.requestFocus();
      member = member.copyWith(spendingFocusNode: focusNode);
    }

    memberMap.update(memberId, (value) => member);

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: memberMap)),
            ));
  }
}

class EntryNextFocus implements AppAction {
  final PaidOrSpent paidOrSpent;

  EntryNextFocus({this.paidOrSpent});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> memberMap = Map.from(entry.entryMembers);
    List<EntryMember> memberList = memberMap.values.toList();
    int memberFocusIndex;
    bool membersHaveFocus = false;
    FocusNode commentFocusNode = appState.singleEntryState.commentFocusNode.value;
    FocusNode tagFocusNode = appState.singleEntryState.tagFocusNode.value;

    for (int i = 0; i < memberList.length; i++) {
      FocusNode focusNode;
      if (memberList[i].spendingFocusNode.hasFocus) {
        //remove focus from current focused member
        memberFocusIndex = i;
        focusNode = memberList[i].spendingFocusNode;
        focusNode.unfocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(spendingFocusNode: focusNode));
      } else if (memberList[i].payingFocusNode.hasFocus) {
        //remove focus from current focused member
        memberFocusIndex = i;
        focusNode = memberList[i].payingFocusNode;
        focusNode.unfocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(payingFocusNode: focusNode));
      } else if (paidOrSpent == PaidOrSpent.paid &&
          memberFocusIndex != null &&
          i > memberFocusIndex &&
          memberList[i].paying == true) {
        //focus on next paying member if there is one
        focusNode = memberList[i].payingFocusNode;
        focusNode.requestFocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(payingFocusNode: focusNode));
        membersHaveFocus = true;
        break;
      } else if (paidOrSpent == PaidOrSpent.spent &&
          memberFocusIndex != null &&
          i > memberFocusIndex &&
          memberList[i].spending == true) {
        focusNode = memberList[i].spendingFocusNode;
        focusNode.requestFocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(spendingFocusNode: focusNode));
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

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: memberMap)),
              commentFocusNode: Maybe.some(commentFocusNode),
              tagFocusNode: Maybe.some(tagFocusNode),
            ));
  }
}

Tag _incrementCategoryFrequency({@required String categoryId, @required Tag updatedTag}) {
  Map<String, int> tagCategoryFrequency = Map.from(updatedTag.tagCategoryFrequency);

  //adds frequency to tag for the category if present, adds it otherwise
  tagCategoryFrequency.update(categoryId, (value) => value + 1, ifAbsent: () => 1);
  updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);

  return updatedTag;
}

Tag incrementCategoryAndLogFrequency({@required Tag updatedTag, String categoryId}) {
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

Tag decrementCategoryAndLogFrequency({@required Tag updatedTag, @required String categoryId}) {
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

Map<String, EntryMember> _setMembersList({@required Log log, @required String memberId, @required String userId}) {
  //adds the log members to the entry member list when creating a new entry of changing logs

  Map<String, EntryMember> members = {};

  log.logMembers.forEach((key, value) {
    members.putIfAbsent(
        key,
        () => EntryMember(
              uid: value.uid,
              order: value.order,
              paying: userId == value.uid ? true : false,
              payingController: TextEditingController(),
              spendingController: TextEditingController(),
              payingFocusNode: FocusNode(),
              spendingFocusNode: FocusNode(),
            ));
  });

  if (memberId != null) {
    //sets the selected user as paying unless the action is triggered from the FAB
    members.updateAll((key, value) => value.copyWith(paying: key == memberId ? true : false));
  }

  return members;
}
