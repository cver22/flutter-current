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
    entry = entry.copyWith(logId: log.id, currency: log.currency, dateTime: DateTime.now(), tagIDs: []);
    print('this is my new entry $entry');
    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(entry),
            selectedTag: Maybe.none(),
            logTagList: log.tags,
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

    return _updateSingleEntryState(
        appState,
        (entryState) => entryState.copyWith(
            selectedEntry: Maybe.some(entry),
            selectedTag: Maybe.none(),
            logTagList: log.tags,
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
    Env.logsFetcher.updateLog(log.copyWith(tags: Env.store.state.singleEntryState.logTagList));

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
  final List<String> tagIDs;

  UpdateSelectedEntry(
      {this.id,
      this.logId,
      this.currency,
      this.active,
      this.category,
      this.subcategory,
      this.amount,
      this.comment,
      this.dateTime,
      this.tagIDs});

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
            tagIDs: tagIDs,
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
/*
class IncrementCategoryTagFrequency implements Action {
  final String categoryId;
  final String tagId;

  IncrementCategoryTagFrequency({@required this.categoryId, @required this.tagId});

  @override
  AppState updateState(AppState appState) {
    List<MyCategory> categories = Env.store.state.singleEntryState.logCategoryList;

    if (appState.singleEntryState.selectedEntry.value?.categoryId != null) {
      int index = categories.lastIndexWhere((e) => e.id == categoryId);
      MyCategory category = categories[index];
      int tagFrequency = 0;
      //TODO experiences an error when the first tag is added

      categories.removeAt(index);
      if (category.tagIdFrequency?.isEmpty ?? true) {
        category = category.copyWith(tagIdFrequency: {});
      }

      if (category?.tagIdFrequency?.containsKey(tagId) != null) {
        tagFrequency = category?.tagIdFrequency[tagId];
      }

      category.tagIdFrequency.update(
        tagId,
        (value) => tagFrequency++,
        ifAbsent: () => 1,
      );
      print('increment tagfrequency: $tagFrequency');
      category = category.copyWith(tagIdFrequency: category.tagIdFrequency);

      if (index >= categories.length) {
        categories.add(category);
      } else {
        categories.insert(index, category);
      }
    }
    return _updateSingleEntryState(
      appState,
      (entryState) => entryState.copyWith(logCategoryList: categories),
    );
  }
}

class DecrementCategoryTagFrequency implements Action {
  final String categoryId;
  final String tagId;

  DecrementCategoryTagFrequency({@required this.categoryId, @required this.tagId});

  @override
  AppState updateState(AppState appState) {
    List<MyCategory> categories = Env.store.state.singleEntryState.logCategoryList;
    if (appState.singleEntryState.selectedEntry.value?.categoryId != null) {
      int index = categories.lastIndexWhere((e) => e.id == categoryId);
      MyCategory category = categories[index];
      categories.removeAt(index);

      if (category.tagIdFrequency == null) {
        category = category.copyWith(tagIdFrequency: Map<String, int>());
      }

      int tagFrequency = 0;

      if (category?.tagIdFrequency?.containsKey(tagId) != null) {
        tagFrequency = category?.tagIdFrequency[tagId];
      }

      print('tag frequency $tagFrequency');
      //only decrements and replaces the category tag frequency if the tag is used at least once elsewhere
      if (tagFrequency >= 1) {
        category.tagIdFrequency.update(
          tagId,
          (value) => tagFrequency--,
          ifAbsent: () => 0,
        );
        category = category.copyWith(tagIdFrequency: category.tagIdFrequency);
      }
      print('removing tag');
      category.tagIdFrequency.removeWhere((key, value) => value < 1);
      //TODO how to remove the tag if its less than 1

      if (index >= categories.length) {
        categories.add(category);
      } else {
        categories.insert(index, category);
      }
    }
    return _updateSingleEntryState(
      appState,
      (entryState) => entryState.copyWith(logCategoryList: categories),
    );
  }
}*/

class DeleteEntry implements Action {
  @override
  AppState updateState(AppState appState) {
    Env.store.dispatch(SingleEntryProcessing());
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    EntriesState updatedEntriesState = appState.entriesState;
    updatedEntriesState.entries.removeWhere((key, value) => key == entry.id);

    Env.entriesFetcher.deleteEntry(entry);
    Env.store.dispatch(ClearEntryState());
    //TODO ask Boris, is this kind of action legal, or do I need to pass the revised state back to this action?

    return _updateEntriesState(appState, (entriesState) => updatedEntriesState);
  }
}
