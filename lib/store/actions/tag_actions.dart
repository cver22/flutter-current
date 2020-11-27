part of 'actions.dart';

AppState _updateTagState(
  AppState appState,
  TagState update(TagState tagState),
) {
  return appState.copyWith(tagState: update(appState.tagState));
}

class UpdateTagState implements Action {
  final Maybe<Tag> selectedTag;
  final List<Tag> newTags;

  UpdateTagState({this.selectedTag, this.newTags});

  @override
  AppState updateState(AppState appState) {
    return _updateTagState(
        appState,
        (tagState) => tagState.copyWith(
              selectedTag: selectedTag,
              newTags: newTags,
            ));
  }
}
