part of 'actions.dart';

AppState _updateTagState(
  AppState appState,
  TagState update(TagState tagState),
) {
  return appState.copyWith(tagState: update(appState.tagState));
}

AppState _updateTags(
  AppState appState,
  void updateInPlace(Map<String, Tag> tags),
) {
  Map<String, Tag> cloneMap = Map.from(appState.tagState.tags);
  updateInPlace(cloneMap);
  return _updateTagState(appState, (tagState) => tagState.copyWith(tags: cloneMap));
}

class SetTagsLoading implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateTagState(appState, (tagState) => tagState.copyWith(isLoading: true));
  }
}

class SetTagsLoaded implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateTagState(appState, (tagState) => tagState.copyWith(isLoading: false));
  }
}

class SetTags implements Action {
  final Iterable<Tag> tagList;

  SetTags({this.tagList});

  @override
  AppState updateState(AppState appState) {
    return _updateTags(appState, (tag) {
      tag.addEntries(
        tagList.map(
          (tag) => MapEntry(tag.id, tag),
        ),
      );
    });
  }
}

class AddUpdateTags implements Action {
  AppState updateState(AppState appState) {
    List<Tag> tagsToAddToDatabase = [];
    List<Tag> tagsToUpdateInDatabase = [];
    Map<String, Tag> addedUpdatedTags = appState.singleEntryState.tags;
    Map<String, Tag> masterTagList = appState.tagState.tags;

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

    Env.tagFetcher.batchAddUpdate(addedTags: tagsToAddToDatabase, updatedTags: tagsToUpdateInDatabase);

    return _updateTagState(appState, (tagState) => tagState.copyWith(tags: masterTagList));
  }
}
