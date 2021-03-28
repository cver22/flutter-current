import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../app/models/app_state.dart';
import '../../categories/categories_model/app_category/app_category.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../entry/entry_model/single_entry_state.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../member/member_model/entry_member_model/entry_member.dart';
import '../../settings/settings_model/settings.dart';
import '../../tags/tag_model/tag.dart';
import '../../currency/currency_utils/currency_formatters.dart';
import '../../utils/db_consts.dart';
import '../../utils/maybe.dart';
import 'app_actions.dart';

//to be used when user updates a parameter of the entry. Generally not when they add/edit of categories/subcategories/tags
AppState Function(AppState) _userUpdateSingleEntryState(SingleEntryState update(singleEntryState)) {
  return (state) => state.copyWith(singleEntryState: update(state.singleEntryState.copyWith(userUpdated: true)));
}

///*SET, SELECT, SAVE ENTRY*//

class EntrySetNew implements AppAction {
  //sets new entry and resets all entry data not yet available
  final String logId;
  final String memberId;

  EntrySetNew({this.logId, @required this.memberId});

  @override
  AppState updateState(AppState appState) {
    AppEntry entry = AppEntry();
    Log log;
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    String defaultLogId = appState.settingsState.settings?.value?.defaultLogId;
    Settings settings = appState.settingsState.settings.value;

    //TODO possibly abstract this away as the setting log dropdown probably uses similar logic
    if (logId != null) {
      //add entry triggered from a selected log
      log = logs[logId];
    } else if (defaultLogId != null && logs.containsKey(defaultLogId)) {
      log = logs[defaultLogId];
    } else {
      //current default logId is not set or refers to a deleted log, change default to first log
      defaultLogId = logs.keys.first;
      log = logs[defaultLogId];
      settings = settings.copyWith(defaultLogId: defaultLogId);
      Env.settingsFetcher.writeAppSettings(settings);
    }

    Map<String, Tag> tags = Map.from(appState.tagState.tags)..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> members = _setMembersList(log: log, memberId: memberId);

    entry = entry.copyWith(
        logId: log.id,
        currency: log.currency,
        dateTime: DateTime.now(),
        tagIDs: [],
        entryMembers: members,
        id: '${appState.authState.user.value.id}-${Uuid().v4()}');

    Env.settingsFetcher.writeAppSettings(settings);

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
        updateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              selectedTag: Maybe<Tag>.some(Tag(
                tagCategoryFrequency: <String, int>{},
                tagSubcategoryFrequency: <String, int>{},
              )),
              tags: tags,
              categories: List<AppCategory>.from(log.categories),
              subcategories: List<AppCategory>.from(log.subcategories),
              processing: false,
              commentFocusNode: Maybe<FocusNode>.some(FocusNode()),
              tagFocusNode: Maybe<FocusNode>.some(FocusNode()),
              newEntry: true,
            )),
      ],
    );
  }
}

class EntrySelectEntry implements AppAction {
  //sets selected entry and resets all entry data not yet available
  final String entryId;

  EntrySelectEntry({@required this.entryId});

  @override
  AppState updateState(AppState appState) {
    AppEntry entry = appState.entriesState.entries[entryId];
    Log log = appState.logsState.logs.values.firstWhere((element) => element.id == entry.logId);
    Map<String, Tag> tags = Map.from(appState.tagState.tags)..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> entryMembers = Map.from(entry.entryMembers);
    entryMembers.updateAll((key, value) => value.copyWith(
          payingController: TextEditingController(text: formattedAmount(value: value?.paid)),
          spendingController: TextEditingController(text: formattedAmount(value: value?.spent)),
          payingFocusNode: FocusNode(),
          spendingFocusNode: FocusNode(),
        ));

    return updateSubstates(
      appState,
      [
        updateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry.copyWith(entryMembers: entryMembers)),
              selectedTag: Maybe.some(Tag(
                tagCategoryFrequency: <String, int>{},
                tagSubcategoryFrequency: <String, int>{},
              )),
              tags: tags,
              categories: List<AppCategory>.from(log.categories),
              subcategories: List<AppCategory>.from(log.subcategories),
              processing: false,
              commentFocusNode: Maybe<FocusNode>.some(FocusNode()),
              tagFocusNode: Maybe<FocusNode>.some(FocusNode()),
              newEntry: false,
              canSave: true,
            )),
      ],
    );
  }
}

class EntryAddUpdateEntryAndTags implements AppAction {
  final AppEntry entry;

  EntryAddUpdateEntryAndTags({this.entry});

  AppState updateState(AppState appState) {
    List<Tag> tagsToAddToDatabase = [];
    List<Tag> tagsToUpdateInDatabase = [];
    Map<String, Tag> addedUpdatedTags = Map.from(appState.singleEntryState.tags);
    Map<String, Tag> masterTagList = Map.from(appState.tagState.tags);
    Map<String, AppEntry> entries = Map.from(appState.entriesState.entries);
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    AppEntry updatedEntry = entry;
    bool newEntry = appState.singleEntryState.newEntry;

    Env.store.dispatch(EntryProcessing());

    //update entry for state and database
    if (!newEntry &&
        updatedEntry !=
            appState.entriesState.entries.entries
                .map((e) => e.value)
                .toList()
                .firstWhere((element) => element.id == entry.id)) {
      //update entry if id is not null and thus already exists an the entry has been modified
      Env.entriesFetcher.updateEntry(entry);
    } else if (newEntry) {
      //save new entry
      Env.entriesFetcher.addEntry(updatedEntry);
    }

    //update entries for total only
    entries.update(updatedEntry.id, (value) => updatedEntry, ifAbsent: () => updatedEntry);

    //update tags state
    addedUpdatedTags.forEach((key, tag) {
      if (!masterTagList.containsKey(key)) {
        //tag doesn't exist and will be added

        masterTagList.putIfAbsent(key, () => tag);
        tagsToAddToDatabase.add(tag);
      } else if (masterTagList.containsKey(key) && masterTagList[key] != tag) {
        // if the tag exists and has changed, update it
        masterTagList.update(key, (value) => tag); // update the local tag map
        tagsToUpdateInDatabase.add(tag); //updates list of tags that will be sent to database
      }
    });

    //update tags database
    Env.tagFetcher.batchAddUpdate(addedTags: tagsToAddToDatabase, updatedTags: tagsToUpdateInDatabase);

    //TODO update logs total in state?
    //logs.updateAll((key, log) => _updateLogMemberTotals(entries: entries.values.toList(), log: log));

    //update log categories and subcategories if they have changed
    logs = updateLogCategoriesSubcategoriesFromEntry(appState: appState, logId: updatedEntry.logId, logs: logs);

    return updateSubstates(
      appState,
      [
        updateLogsState((logsState) => logsState.copyWith(logs: logs)),
        updateTagState((tagState) => tagState.copyWith(tags: masterTagList)),
        updateSingleEntryState((singleEntryState) => SingleEntryState.initial()),
      ],
    );
  }
}

/*ADD UPDATE DELETE ENTRY SECTION*/

class EntryProcessing implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [updateSingleEntryState((singleEntryState) => singleEntryState.copyWith(processing: true))],
    );
  }
}

class EntryClearState implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [updateSingleEntryState((singleEntryState) => SingleEntryState.initial())],
    );
  }
}

///*CHANGE ENTRY VALUES*/

class EntryUpdateCurrency implements AppAction {
  final String currency;

  EntryUpdateCurrency({@required this.currency});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe<AppEntry>.some(singleEntryState.selectedEntry.value.copyWith(currency: currency)))),
        updateCurrencyState((currencyState) => currencyState.copyWith(searchCurrencies: <Currency>[])),
      ],
    );
  }
}

class EntryUpdateComment implements AppAction {
  final String comment;

  EntryUpdateComment({@required this.comment});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe<AppEntry>.some(singleEntryState.selectedEntry.value.copyWith(comment: comment)))),
      ],
    );
  }
}

class EntryUpdateDateTime implements AppAction {
  final DateTime dateTime;

  EntryUpdateDateTime({this.dateTime});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe<AppEntry>.some(singleEntryState.selectedEntry.value.copyWith(dateTime: dateTime)))),
      ],
    );
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

class EntrySelectCategory implements AppAction {
  final String newCategoryId;

  EntrySelectCategory({@required this.newCategoryId});

  @override
  AppState updateState(AppState appState) {
    String updatedCategory = newCategoryId;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    String oldCategoryId = entry.categoryId;
    String newSubcategoryId = NO_SUBCATEGORY;

    //set subcategory to OTHER if category has been selected
    if (newCategoryId != NO_CATEGORY && newCategoryId != TRANSFER_FUNDS) {
      newSubcategoryId = appState.singleEntryState.subcategories
          .firstWhere((element) => element.parentCategoryId == newCategoryId && element.id.contains(OTHER))
          .id;
    }

    tags = categoryOrSubcategoryUpdateAllTagFrequencies(
        entry: entry,
        oldAppCategory: oldCategoryId,
        newAppCategory: updatedCategory,
        tags: tags,
        categoryOrSubcategory: CategoryOrSubcategory.category);

    tags = categoryOrSubcategoryUpdateAllTagFrequencies(
        entry: entry,
        oldAppCategory: entry?.subcategoryId,
        newAppCategory: newSubcategoryId,
        tags: tags,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry:
                  Maybe<AppEntry>.some(entry.copyWith(categoryId: newCategoryId, subcategoryId: newSubcategoryId)),
              tags: tags,
            )),
      ],
    );
  }
}

class EntrySelectSubcategory implements AppAction {
  final String subcategory;

  EntrySelectSubcategory({this.subcategory});

  @override
  AppState updateState(AppState appState) {
    String updatedSubcategory = subcategory;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    String oldSubcategoryId = entry?.subcategoryId;

    tags = categoryOrSubcategoryUpdateAllTagFrequencies(
        tags: tags,
        oldAppCategory: oldSubcategoryId,
        newAppCategory: updatedSubcategory,
        entry: entry,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry:
                  Maybe<AppEntry>.some(singleEntryState.selectedEntry.value.copyWith(subcategoryId: subcategory)),
              tags: tags,
            )),
      ],
    );
  }
}

class EntryReorderCategories implements AppAction {
  final int newIndex;
  final int oldIndex;

  EntryReorderCategories({@required this.newIndex, @required this.oldIndex});

  AppState updateState(AppState appState) {
    List<AppCategory> categories = List.from(appState.singleEntryState.categories);
    int categoryNewIndex = newIndex;

    if (newIndex > categories.length) categoryNewIndex = categories.length;
    if (oldIndex < newIndex) categoryNewIndex--;

    AppCategory category = categories[oldIndex];
    categories.remove(category);
    categories.insert(categoryNewIndex, category);

    return updateSubstates(
      appState,
      [updateSingleEntryState((singleEntryState) => singleEntryState.copyWith(categories: categories))],
    );
  }
}

class EntryReorderSubcategories implements AppAction {
  final List<AppCategory> reorderedSubcategories;
  final int newIndex;
  final int oldIndex;

  EntryReorderSubcategories({@required this.newIndex, @required this.oldIndex, @required this.reorderedSubcategories});

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

    return updateSubstates(
      appState,
      [updateSingleEntryState((singleEntryState) => singleEntryState.copyWith(subcategories: subcategories))],
    );
  }
}

class EntryAddEditCategory implements AppAction {
  final AppCategory category;

  EntryAddEditCategory({@required this.category});

  AppState updateState(AppState appState) {
    List<AppCategory> categories = List.from(appState.singleEntryState.categories);
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    if (category.id == null) {
      AppCategory newCategory = category.copyWith(id: Uuid().v4());
      categories.add(newCategory);
      subcategories.add(
          AppCategory(parentCategoryId: newCategory.id, name: 'Other', emojiChar: '🤷', id: '$OTHER${Uuid().v4()}'));
    } else {
      categories[categories.indexWhere((entry) => entry.id == category.id)] = category;
    }

    return updateSubstates(
      appState,
      [
        updateSingleEntryState(
            (singleEntryState) => singleEntryState.copyWith(categories: categories, subcategories: subcategories))
      ],
    );
  }
}

class EntryDeleteCategory implements AppAction {
  final AppCategory category;

  EntryDeleteCategory({@required this.category});

  AppState updateState(AppState appState) {
    List<AppCategory> categories = List.from(appState.singleEntryState.categories);
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    bool _canDeleteCategory = canDeleteCategory(id: category.id);

    //remove category and its subcategories if the category is not "no category"
    if (_canDeleteCategory) {
      categories.removeWhere((e) => e.id == category.id);
      subcategories.removeWhere((e) => e.parentCategoryId == category.id);
    }
    if (category.id == entry.categoryId) {
      //if we deleted the category used by the entry, reset the entry to no category or subcategory
      entry = AppEntry(
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

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
            categories: categories, subcategories: subcategories, selectedEntry: Maybe<AppEntry>.some(entry)))
      ],
    );
  }
}

class EntryAddEditSubcategory implements AppAction {
  final AppCategory subcategory;

  EntryAddEditSubcategory({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    String previousParentId = entry.categoryId;

    if (subcategory.id == null) {
      //add new subcategory
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    } else {
      //edit subcategory
      subcategories[subcategories.indexWhere((entry) => entry.id == subcategory.id)] = subcategory;

      //if the parent category of the subcategory was changed and thus the entry category changed, decrement the previous category and increment the new category
      if (previousParentId != subcategory.parentCategoryId && entry.subcategoryId == subcategory.id) {
        entry.tagIDs.forEach((tagId) {
          Tag tag = tags[tagId];

          tag = _decrementAppCategoryFrequency(
              categoryId: previousParentId, updatedTag: tag, categoryOrSubcategory: CategoryOrSubcategory.category);
          tag = _incrementAppCategoryFrequency(
              appCategoryId: subcategory.parentCategoryId,
              updatedTag: tag,
              categoryOrSubcategory: CategoryOrSubcategory.category);

          tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
        });
        entry = entry.copyWith(categoryId: subcategory.parentCategoryId);
      }
    }

    //update the subcategory as well as the category if the parent has changed
    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
            subcategories: subcategories, tags: tags, selectedEntry: Maybe<AppEntry>.some(entry)))
      ],
    );
  }
}

class EntryDeleteSubcategory implements AppAction {
  final AppCategory subcategory;

  EntryDeleteSubcategory({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<AppCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    bool _canDeleteSubcategory = canDeleteSubcategory(subcategory: subcategory);

    if (_canDeleteSubcategory) {
      subcategories.removeWhere((e) => e.id == subcategory.id);
      if (subcategory.id == entry.subcategoryId) {
        //TODO this should auto select the "other" subcategory

      }
    }

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) =>
            singleEntryState.copyWith(subcategories: subcategories, selectedEntry: Maybe<AppEntry>.some(entry)))
      ],
    );
  }
}

///*MEMBER ACTIONS*/

class EntryUpdateMemberPaidAmount implements AppAction {
  final int paidValue;
  final EntryMember member;

  EntryUpdateMemberPaidAmount({@required this.paidValue, @required this.member});

  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
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

    members.updateAll((key, value) {
      return value.copyWith(userEditedSpent: false);
    });

    members = _divideSpendingEvenly(amount: amount, members: members);
    entry = entry.copyWith(amount: amount, entryMembers: members);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              canSave: _canSave(entry: entry),
            ))
      ],
    );
  }
}

class EntryUpdateMemberSpentAmount implements AppAction {
  final int spentValue;
  final EntryMember member;

  EntryUpdateMemberSpentAmount({this.spentValue = 0, @required this.member});

  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //update amount spent by individual member
    members.update(member.uid, (value) => member.copyWith(spent: spentValue, userEditedSpent: true));

    members = _divideSpendingEvenly(amount: entry.amount, members: members);
    entry = entry.copyWith(entryMembers: members);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              canSave: _canSave(entry: entry),
            ))
      ],
    );
  }
}

class EntryDivideRemainingSpending implements AppAction {
  //if user has updated all members spent amounts and there is some remaining value, distribute the remaining amount evenly

  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);

    members = _distributeRemainingSpending(amount: entry.amount, members: members);
    entry = entry.copyWith(entryMembers: members);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              canSave: _canSave(entry: entry),
            ))
      ],
    );
  }
}

class EntryResetMemberSpendingToAll implements AppAction {
  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);

    members.updateAll((key, member) {
      return member.copyWith(userEditedSpent: false);
    });

    members = _divideSpendingEvenly(amount: entry.amount, members: members);
    entry = entry.copyWith(entryMembers: members);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              canSave: _canSave(entry: entry),
            ))
      ],
    );
  }
}

class EntryToggleMemberPaying implements AppAction {
  final EntryMember member;

  EntryToggleMemberPaying({@required this.member});

  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
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
    entry = entry.copyWith(entryMembers: members, amount: amount);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              canSave: _canSave(entry: entry),
            ))
      ],
    );
  }
}

class EntryToggleMemberSpending implements AppAction {
  final EntryMember member;

  EntryToggleMemberSpending({@required this.member});

  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
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
      member = member.copyWith(spending: !member.spending, spent: 0, userEditedSpent: false);
      members.update(member.uid, (value) => member);
    }

    //redistributes expense based on revision of who is paying
    members = _divideSpendingEvenly(amount: entry.amount, members: members);
    entry = entry.copyWith(entryMembers: members);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              canSave: _canSave(entry: entry),
            ))
      ],
    );
  }
}

///*TAGS SECTION*/

class EntryAddUpdateTag implements AppAction {
  final Tag tag;

  EntryAddUpdateTag({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag addedUpdatedTag = tag;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Tag existingTag;
    bool duplicateNewTag = false;

    for (Tag value in tags.values.toList()) {
      if (value.name.toLowerCase() == tag.name.toLowerCase()) {
        existingTag = value;
        break;
      }
    }

    for (Tag value in appState.singleEntryState.tags.values.toList()) {
      if (value.name.toLowerCase() == tag.name.toLowerCase()) {
        //user attempting to add duplicate new tags
        duplicateNewTag = true;
        break;
      }
    }
    if (!duplicateNewTag) {
      if (addedUpdatedTag.id == null) {
        if (existingTag == null) {
          //save new tag using the user id to help minimize chance of duplication of entry ids in the database
          addedUpdatedTag = addedUpdatedTag.copyWith(
            id: '${Uuid().v4()}-${appState.authState.user.value.id}',
            logId: entry.logId,
            tagLogFrequency: 1,
            tagCategoryFrequency: <String, int>{},
            tagSubcategoryFrequency: <String, int>{},
            memberList: entry.entryMembers.keys.toList(),
          );
        } else {
          //the tag already exists in the log, add to the entry and increment the log frequency
          addedUpdatedTag = existingTag.incrementTagLogFrequency();
        }

        entry.tagIDs.add(addedUpdatedTag.id);

        addedUpdatedTag = _incrementCategorySubcategoryFrequency(
            updatedTag: addedUpdatedTag, categoryId: entry?.categoryId, subcategoryId: entry?.subcategoryId);
      }

      //updates existing tag or add it
      tags.update(addedUpdatedTag.id, (value) => addedUpdatedTag, ifAbsent: () => addedUpdatedTag);
    }

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry),
              selectedTag: Maybe<Tag>.some(Tag(
                tagCategoryFrequency: <String, int>{},
                tagSubcategoryFrequency: <String, int>{},
              )),
              tags: tags,
              searchedTags: <Tag>[],
              search: Maybe<String>.none(),
            ))
      ],
    );
  }
}

class EntrySelectDeselectTag implements AppAction {
  final Tag tag;

  EntrySelectDeselectTag({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag selectedDeselectedTag = tag;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    List<String> entryTagIds = List.from(entry.tagIDs);
    bool entryHasTag = false;

    //determines if the tag is in the entry or in another list
    entryTagIds.forEach((element) {
      if (element == tag.id) {
        entryHasTag = true;
      }
    });

    if (entryHasTag) {
      //remove tag from entry if present

      selectedDeselectedTag = decrementCategorySubcategoryLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry.categoryId, subcategoryId: entry.subcategoryId);

      //remove the tag from the entry tag list
      entryTagIds.remove(tag.id);
    } else {
      //add tag to entry if not present

      //increment use of tag for this category
      selectedDeselectedTag = _incrementCategoryAndLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry.categoryId, subcategoryId: entry.subcategoryId);

      //remove the tag from the entry tag list
      entryTagIds.add(tag.id);
    }

    tags.update(selectedDeselectedTag.id, (value) => selectedDeselectedTag, ifAbsent: () => selectedDeselectedTag);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe<AppEntry>.some(entry.copyWith(tagIDs: entryTagIds)),
            tags: tags,
            searchedTags: <Tag>[],
            search: Maybe<String>.none())),
      ],
    );
  }
}

class EntrySetSearchedTags implements AppAction {
  final String search;

  EntrySetSearchedTags({this.search});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tagMap = Map.from(appState.singleEntryState.tags);
    List<Tag> tags = tagMap.values.toList();
    List<Tag> searchedTags = [];
    Maybe<String> searchMaybe = search != null && search.length > 0 ? Maybe.some(search) : Maybe.none();
    int maxTags = MAX_TAGS;
    List<String> selectedTagIds = List.from(appState.singleEntryState.selectedEntry.value.tagIDs);

    searchedTags = buildSearchedTagsList(tags: tags, tagIds: selectedTagIds, maxTags: maxTags, search: search);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState(
            (singleEntryState) => singleEntryState.copyWith(searchedTags: searchedTags, search: searchMaybe)),
      ],
    );
  }
}

class EntryDeleteTag implements AppAction {
  final Tag tag;

  EntryDeleteTag({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);
    Map<String, Tag> entryTagsMap = Map.from(appState.singleEntryState.tags);
    tagsMap.removeWhere((key, value) => key == tag.id);
    entryTagsMap.removeWhere((key, value) => key == tag.id);

    Env.tagFetcher.deleteTag(tag);

    return updateSubstates(
      appState,
      [
        updateTagState((tagState) => tagState.copyWith(tags: tagsMap)),
        updateSingleEntryState((singleEntryState) => singleEntryState.copyWith(tags: entryTagsMap, userUpdated: true)),
      ],
    );
  }
}

///*FOCUS*//

class EntryMemberFocus implements AppAction {
  final String memberId;
  final PaidOrSpent paidOrSpent;

  EntryMemberFocus({@required this.memberId, @required this.paidOrSpent});

  @override
  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> memberMap = Map.from(entry.entryMembers);
    EntryMember member = memberMap[memberId];
    FocusNode focusNode;

    if (paidOrSpent == PaidOrSpent.paid) {
      focusNode = member.payingFocusNode;
      focusNode.requestFocus();
      member = member.copyWith(payingFocusNode: focusNode);
    } else if (paidOrSpent == PaidOrSpent.spent) {
      focusNode = member.spendingFocusNode;
      focusNode.requestFocus();
      member = member.copyWith(spendingFocusNode: focusNode);
    }

    memberMap.update(memberId, (value) => member);

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) =>
            singleEntryState.copyWith(selectedEntry: Maybe<AppEntry>.some(entry.copyWith(entryMembers: memberMap)))),
      ],
    );
  }
}

class EntryNextFocus implements AppAction {
  final PaidOrSpent paidOrSpent;

  EntryNextFocus({this.paidOrSpent});

  @override
  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
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

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry.copyWith(entryMembers: memberMap)),
              commentFocusNode: Maybe<FocusNode>.some(commentFocusNode),
              tagFocusNode: Maybe<FocusNode>.some(tagFocusNode),
            )),
      ],
    );
  }
}

class EntryClearAllFocus implements AppAction {
  @override
  AppState updateState(AppState appState) {
    AppEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> memberMap = Map.from(entry.entryMembers);
    List<EntryMember> memberList = memberMap.values.toList();
    FocusNode commentFocusNode = appState.singleEntryState.commentFocusNode.value;
    FocusNode tagFocusNode = appState.singleEntryState.tagFocusNode.value;

    for (int i = 0; i < memberList.length; i++) {
      FocusNode spendingFocus;
      FocusNode payingFocus;

      spendingFocus = memberList[i].spendingFocusNode;
      spendingFocus.unfocus();
      payingFocus = memberList[i].payingFocusNode;
      payingFocus.unfocus();
      memberMap.update(memberList[i].uid,
          (value) => memberList[i].copyWith(spendingFocusNode: spendingFocus, payingFocusNode: payingFocus));
    }

    commentFocusNode.unfocus();
    tagFocusNode.unfocus();

    return updateSubstates(
      appState,
      [
        _userUpdateSingleEntryState((singleEntryState) => singleEntryState.copyWith(
              selectedEntry: Maybe<AppEntry>.some(entry.copyWith(entryMembers: memberMap)),
              commentFocusNode: Maybe<FocusNode>.some(commentFocusNode),
              tagFocusNode: Maybe<FocusNode>.some(tagFocusNode),
            )),
      ],
    );
  }
}

///*METHODS*/

Tag _incrementCategoryAndLogFrequency(
    {@required Tag updatedTag, @required String categoryId, @required String subcategoryId}) {
  updatedTag = _incrementCategorySubcategoryFrequency(
      updatedTag: updatedTag, categoryId: categoryId, subcategoryId: subcategoryId);

  //increment use of tag for this log
  updatedTag = updatedTag.incrementTagLogFrequency();

  return updatedTag;
}

Tag _incrementCategorySubcategoryFrequency(
    {@required Tag updatedTag, @required String categoryId, @required String subcategoryId}) {
  //increment use of tag for this category if present
  updatedTag = _incrementAppCategoryFrequency(
      appCategoryId: categoryId, updatedTag: updatedTag, categoryOrSubcategory: CategoryOrSubcategory.category);

  //increment use of tag for this subcategory if present
  updatedTag = _incrementAppCategoryFrequency(
      appCategoryId: subcategoryId, updatedTag: updatedTag, categoryOrSubcategory: CategoryOrSubcategory.subcategory);

  return updatedTag;
}

Tag _incrementAppCategoryFrequency(
    {@required String appCategoryId, @required Tag updatedTag, @required CategoryOrSubcategory categoryOrSubcategory}) {
  print('increment tag: $updatedTag');

  Map<String, int> tagCategoryFrequency = const {};
  if (categoryOrSubcategory == CategoryOrSubcategory.category) {
    tagCategoryFrequency = Map<String, int>.from(updatedTag.tagCategoryFrequency);
  } else {
    tagCategoryFrequency = Map<String, int>.from(updatedTag.tagSubcategoryFrequency);
  }

  //adds frequency to tag for the category if present, adds it otherwise
  tagCategoryFrequency.update(appCategoryId, (value) => value + 1, ifAbsent: () => 1);

  if (categoryOrSubcategory == CategoryOrSubcategory.category) {
    updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);
  } else {
    updatedTag = updatedTag.copyWith(tagSubcategoryFrequency: tagCategoryFrequency);
  }
  print('incremented tag: $updatedTag');

  return updatedTag;
}

Tag decrementCategorySubcategoryLogFrequency(
    {@required Tag updatedTag, @required String categoryId, String subcategoryId}) {
  updatedTag =
      _decrementCategorySubcategory(updatedTag: updatedTag, categoryId: categoryId, subcategoryId: subcategoryId);

  //decrement use of tag for this log
  updatedTag = updatedTag.decrementTagLogFrequency();

  return updatedTag;
}

Tag _decrementCategorySubcategory(
    {@required Tag updatedTag, @required String categoryId, @required String subcategoryId}) {
  //decrement use of tag for this category if present
  updatedTag = _decrementAppCategoryFrequency(
      categoryId: categoryId, updatedTag: updatedTag, categoryOrSubcategory: CategoryOrSubcategory.category);
  //decrement use of tag for this subcategory if present
  updatedTag = _decrementAppCategoryFrequency(
      categoryId: subcategoryId, updatedTag: updatedTag, categoryOrSubcategory: CategoryOrSubcategory.subcategory);
  return updatedTag;
}

Tag _decrementAppCategoryFrequency(
    {@required String categoryId, @required Tag updatedTag, @required CategoryOrSubcategory categoryOrSubcategory}) {
  Map<String, int> tagCategoryFrequency = <String, int>{};

  print('decrement tag: $updatedTag');

  if (categoryOrSubcategory == CategoryOrSubcategory.category) {
    tagCategoryFrequency = Map<String, int>.from(updatedTag.tagCategoryFrequency);
  } else {
    tagCategoryFrequency = Map<String, int>.from(updatedTag?.tagSubcategoryFrequency);
  }

  //subtracts frequency to tag for the category if present, adds it otherwise
  tagCategoryFrequency.update(categoryId, (value) => value - 1, ifAbsent: () => 0);
  tagCategoryFrequency.removeWhere(
      (key, value) => value < 1); //removes category frequencies where the tags is no longer used by any entries
  if (categoryOrSubcategory == CategoryOrSubcategory.category) {
    updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);
  } else {
    updatedTag = updatedTag.copyWith(tagSubcategoryFrequency: tagCategoryFrequency);
  }

  print('decremented tag: $updatedTag');

  return updatedTag;
}

Map<String, Tag> categoryOrSubcategoryUpdateAllTagFrequencies(
    {@required AppEntry entry,
    String oldAppCategory,
    @required String newAppCategory,
    @required Map<String, Tag> tags,
    @required CategoryOrSubcategory categoryOrSubcategory}) {
  if (entry.tagIDs.length > 0) {
    entry.tagIDs.forEach((tagId) {
      Tag tag = tags[tagId];

      if (oldAppCategory != null) {
        tag = _decrementAppCategoryFrequency(
            categoryId: oldAppCategory, updatedTag: tag, categoryOrSubcategory: categoryOrSubcategory);
      }

      tag = _incrementAppCategoryFrequency(
          appCategoryId: newAppCategory, updatedTag: tag, categoryOrSubcategory: categoryOrSubcategory);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });
  }

  return tags;
}

Map<String, EntryMember> _divideSpendingEvenly({@required int amount, @required Map<String, EntryMember> members}) {
  Map<String, EntryMember> entryMembers = Map.from(members);
  int membersSpending = 0;
  int remainder = 0;
  int divisibleAmount = amount;

  //if members are spending, add the to the divisor
  entryMembers.forEach((key, member) {
    //member is spending and user has not manually edited the spent value
    if (member.spending == true && !member.userEditedSpent) {
      membersSpending += 1;
    }
  });

  //TODO need to handle the remainder, could possibly do this by dividing the initial value by 3, then subtracting the value each time until the last member is reached
  //TODO, randomly assign the remainder

  if (divisibleAmount != null && divisibleAmount != 0 && membersSpending > 0 && members.length > 1) {
    remainder = divisibleAmount.remainder(membersSpending);

    //if member spent is user set, deduct it from the divisibleAmount
    entryMembers.forEach((key, member) {
      if (member.userEditedSpent && member.spending && member.spent != null) {
        divisibleAmount -= member.spent;
      }
    });

    //spread remaining amount evenly among other spending members
    entryMembers.updateAll((key, member) {
      if (member.spending == true && divisibleAmount != 0 && !member.userEditedSpent) {
        int memberSpentAmount = (divisibleAmount / membersSpending).truncate();

        if (remainder > 0) {
          memberSpentAmount += 1;
          remainder--;
        }

        member.spendingController.value = TextEditingValue(text: formattedAmount(value: memberSpentAmount));
        return member.copyWith(spent: memberSpentAmount);
      } else {
        return member;
      }
    });
  } else {
    entryMembers.updateAll((key, member) {
      return member.copyWith(spent: divisibleAmount);
    });
  }

  return entryMembers;
}

Map<String, EntryMember> _distributeRemainingSpending(
    {@required int amount, @required Map<String, EntryMember> members}) {
  Map<String, EntryMember> entryMembers = Map.from(members);
  int membersSpending = 0;
  int remainder = 0;
  int divisibleAmount = amount;

  entryMembers.forEach((key, member) {
    //member is spending and user has not manually edited the spent value
    if (member.spending == true) {
      membersSpending += 1;
      divisibleAmount -= member.spent;
    }
  });

  //TODO need to handle the remainder, could possibly do this by dividing the initial value by 3, then subtracting the value each time until the last member is reached
  //TODO, randomly assign the remainder

  if (divisibleAmount != null && divisibleAmount != 0) {
    remainder = divisibleAmount.remainder(membersSpending);

    //spread remaining amount evenly among other spending members
    entryMembers.updateAll((key, member) {
      if (member.spending == true && divisibleAmount != 0) {
        int memberSpentAmount = member.spent + (divisibleAmount / membersSpending).truncate();

        if (remainder > 0) {
          memberSpentAmount += 1;
          remainder--;
        }

        member.spendingController.value = TextEditingValue(text: formattedAmount(value: memberSpentAmount));
        return member.copyWith(spent: memberSpentAmount);
      } else {
        return member;
      }
    });
  }

  return entryMembers;
}

Map<String, EntryMember> _setMembersList({@required Log log, @required String memberId}) {
  //adds the log members to the entry member list when creating a new entry of changing logs

  Map<String, EntryMember> members = {};

  log.logMembers.forEach((key, value) {
    members.putIfAbsent(
        key,
        () => EntryMember(
              uid: value.uid,
              order: value.order,
              paying: memberId == value.uid ? true : false,
              payingController: TextEditingController(),
              spendingController: TextEditingController(),
              payingFocusNode: FocusNode(),
              spendingFocusNode: FocusNode(),
            ));
  });

  return members;
}

bool _canSave({AppEntry entry}) {
  bool canSubmit = false;
  if (entry?.amount != null && entry.amount != 0) {
    int totalMemberSpend = 0;

    entry.entryMembers.forEach((key, value) {
      if (value.spending) {
        totalMemberSpend += value.spent;
      }
    });
    if (totalMemberSpend == entry.amount) {
      canSubmit = true;
    }
  }
  return canSubmit;
}
