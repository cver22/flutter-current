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
  final List<Tag> logTagList;
  final List<MyCategory> logCategoryList;
  final bool savingEntry;

  UpdateSingleEntryState(
      {this.selectedEntry, this.selectedTag, this.logTagList, this.logCategoryList, this.savingEntry});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
              selectedEntry: selectedEntry,
              selectedTag: selectedTag,
              logTagList: logTagList,
              logCategoryList: logCategoryList,
              savingEntry: savingEntry,
            ));
  }
}

class SetNewSelectedEntry implements Action {
  //sets new entry and resets all entry data not yet available
  final String logId;

  SetNewSelectedEntry({@required this.logId});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = MyEntry();
    Log log = appState.logsState.logs[logId];
    List<Tag> tagList = appState.tagState.tags.values.where((e) => e.logId == logId).toList();
    entry = entry.copyWith(logId: log.id, currency: log.currency, dateTime: DateTime.now(), tagIDs: []);
    print('this is my new entry $entry');
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(entry),
            selectedTag: Maybe.none(),
            logTagList: tagList,
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
    List<Tag> tagList = appState.tagState.tags.values.where((e) => e.logId == log.id).toList();

    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(entry),
            selectedTag: Maybe.none(),
            logTagList: tagList,
            logCategoryList: log.categories,
            savingEntry: false));
  }
}

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
      Env.entriesFetcher.addEntry(entry.copyWith(id: Uuid().v4(), dateTime: DateTime.now()));
    }

    //updates log with updated tag list
    //Env.logsFetcher.updateLog(log.copyWith(tags: Env.store.state.singleEntryState.logTagList));

    return _updateSingleEntryState(appState, (singleEntryState) => SingleEntryState.initial());
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

class UpdateSelectedEntry implements Action {
  final String id;
  final String logId;
  final String currency;
  final bool active;
  final String category;
  final String subcategory;
  final double amount;
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
        selectedEntry: Maybe.some(
          entryState.selectedEntry.value.copyWith(
            id: id,
            logId: logId,
            currency: currency,
            active: active,
            categoryId: category,
            subcategoryId: subcategory,
            amount: amount,
            comment: comment,
            dateTime: dateTime,
          ),
        ),
      ),
    );
  }
}

class ChangeEntryLog implements Action {
  final Log log;

  ChangeEntryLog({@required this.log});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
      appState,
      (entryState) => entryState.copyWith(
        selectedEntry: Maybe.some(
          entryState.selectedEntry.value.changeLog(log: log),
        ),
      ),
    );
  }
}

class ChangeEntryCategories implements Action {
  final String category;

  ChangeEntryCategories({@required this.category});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
      appState,
      (entryState) => entryState.copyWith(
        selectedEntry: Maybe.some(
          entryState.selectedEntry.value.changeCategories(category: category),
        ),
      ),
    );
  }
}

class AddNewTagToEntry implements Action {
  final Tag newTag;

  AddNewTagToEntry({@required this.newTag});

  @override
  AppState updateState(AppState appState) {
    Tag updatedTag = newTag; //TODO - update the editor to utilize the selectedTagState and pull from there
    List<MyCategory> categories = appState.singleEntryState.logCategoryList;
    List<Tag> logTagList = appState.singleEntryState.logTagList;
    MyEntry currentEntry = appState.singleEntryState.selectedEntry.value;

    if (updatedTag.id == null) {
      updatedTag = updatedTag.copyWith(id: Uuid().v4(), logFrequency: 1);

      logTagList.add(updatedTag);

      currentEntry.tagIDs.add(updatedTag.id);

      if (currentEntry.categoryId != null) {
        MyCategory currentCategory = categories.firstWhere((e) => e.id == currentEntry.categoryId);
        categories.remove(currentCategory);
        Map<String, int> categoryTagIdFrequency = currentCategory.tagIdFrequency;
        if (categoryTagIdFrequency?.isEmpty ?? true) {
          categoryTagIdFrequency = {};
        }

        categoryTagIdFrequency[updatedTag.id] = 1;
        categories.add(currentCategory.copyWith(tagIdFrequency: categoryTagIdFrequency));
      }
    }

    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(currentEntry),
            selectedTag: Maybe.none(),
            logCategoryList: categories,
            logTagList: logTagList));
  }
}

class AddOrRemoveEntryTag implements Action {
  final Tag tag;

  AddOrRemoveEntryTag({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    List<Tag> logTagList = appState.singleEntryState.logTagList;
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    List<String> entryTagIds = entry.tagIDs;
    List<MyCategory> categories = appState.singleEntryState.logCategoryList;
    bool entryHasTag = false;
    MyCategory category;
    Map<String, int> tagIdFrequency = {};

    //determines if the tag is in the entry or in another list
    entryTagIds.forEach((element) {
      if (element == tag.id) {
        entryHasTag = true;
      }
    });

    logTagList.removeWhere((element) => element.id == tag.id);
    if (entryHasTag) {
      //decrement the use of the tag on the log
      logTagList.add(tag.decrement(tag: tag));

      //remove the tag from the entry tag list
      entryTagIds.remove(tag.id);

      //if the categoryId is present decrement the use of the tag for this category
      if (entry?.categoryId != null) {
        categories = _updateCategoriesWithFrequency(
            tagIdFrequency: _decrementTagIdFrequency(categories: categories, entry: entry, tagId: tag.id),
            category: category,
            categories: categories);
      }
    } else {
      //increment the use of the tag on the log
      logTagList.add(tag.incrementTagFrequencies(tag: tag));

      //add the tag to the entry tag list
      entryTagIds.add(tag.id);

      //if the categoryId is present increment the use of the tag for this category
      if (entry?.categoryId != null) {
        category = categories.firstWhere((e) => e.id == entry.categoryId);
        tagIdFrequency = category.tagIdFrequency;
        tagIdFrequency.update(
          tag.id,
          (value) => value++,
          ifAbsent: () => 1,
        );

        categories =
            _updateCategoriesWithFrequency(tagIdFrequency: tagIdFrequency, category: category, categories: categories);
      }
    }

    return _updateSingleEntryState(
        appState,
        (singleEntryState) => singleEntryState.copyWith(
            selectedEntry: Maybe.some(entry.copyWith(tagIDs: entryTagIds)),
            logTagList: logTagList,
            logCategoryList: categories));
  }
}

class DeleteEntry implements Action {
  @override
  AppState updateState(AppState appState) {
    Env.store.dispatch(SingleEntryProcessing());
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    List<MyCategory> categories = appState.singleEntryState.logCategoryList;
    List<Tag> logTagList = appState.singleEntryState.logTagList;
    EntriesState updatedEntriesState = appState.entriesState;
    updatedEntriesState.entries.removeWhere((key, value) => key == entry.id);

    Map<String, int> tagIdFrequency = {};
    entry.tagIDs.forEach((tagId) {
      //updates log list of tags
      Tag tag = logTagList.firstWhere((e) => e.id == tagId);
      logTagList.removeWhere((element) => element.id == tagId);
      logTagList.add(tag.decrement(tag: tag));

      //updates category list of tags
      if (entry?.categoryId != null) {
        MyCategory category = categories.firstWhere((e) => e.id == entry.categoryId);
        tagIdFrequency = _decrementTagIdFrequency(entry: entry, categories: categories, tagId: tagId);
        categories =
            _updateCategoriesWithFrequency(tagIdFrequency: tagIdFrequency, category: category, categories: categories);
      }
    });

    Env.entriesFetcher.deleteEntry(entry);
    Env.logsFetcher.updateLog(appState.logsState.logs[entry.logId].copyWith(tags: logTagList, categories: categories));


    //TODO ask Boris, is this kind of action legal, or do I need to pass the revised state back to this action?
    Env.store.dispatch(ClearEntryState());

    return _updateEntriesState(appState, (entriesState) => updatedEntriesState);
  }
}

Map<String, int> _decrementTagIdFrequency(
    {@required MyEntry entry, @required List<MyCategory> categories, @required String tagId}) {
  MyCategory category = categories.firstWhere((e) => e.id == entry.categoryId);
  Map<String, int> tagIdFrequency = category.tagIdFrequency;

  //decrement if used elsewhere, remove otherwise
  if (tagIdFrequency[tagId] > 1) {
    tagIdFrequency.update(
      tagId,
      (value) => value--,
      ifAbsent: () => 1,
    );
  } else {
    tagIdFrequency.remove(tagId);
  }

  return tagIdFrequency;
}

List<MyCategory> _updateCategoriesWithFrequency(
    {@required Map<String, int> tagIdFrequency, @required MyCategory category, @required List<MyCategory> categories}) {
  int categoryIndex = categories.indexOf(category);
  categories.removeAt(categoryIndex);

  //add tagIdFrequency back to the category
  category = category.copyWith(tagIdFrequency: tagIdFrequency);

  //add category back to categories
  if (categoryIndex >= categories.length) {
    categories.add(category);
  } else {
    categories.insert(categoryIndex, category);
  }

  return categories;
}
