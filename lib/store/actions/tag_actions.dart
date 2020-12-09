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


/*

Log addEditLogTag({Log log, Tag tag}) {
  List<Tag> tags = log.tags;

  //update tag if it already exists
  //otherwise add tag to the list
  if (tag?.id != null) {
    tags[tags.indexWhere((e) => e.id == tag.id)] = tag;
  } else {
    tags.add(tag.copyWith(id: Uuid().v4()));
  }
  return log.copyWith(tags: tags);
}*/
