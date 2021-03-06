import '../../app/models/app_state.dart';
import '../../tags/tag_model/tag.dart';
import '../../tags/tag_model/tag_state.dart';
import 'app_actions.dart';


AppState Function(AppState) _updateTagState(TagState? update(tagState)) {
  return (state) => state.copyWith(tagState: update(state.tagState));
}

AppState _updateTags(
  AppState appState,
  void updateInPlace(Map<String, Tag> tags),
) {
  Map<String, Tag> cloneMap = Map.from(appState.tagState.tags);
  updateInPlace(cloneMap);

  return updateSubstates(
    appState,
    [_updateTagState((tagState) => tagState.copyWith(tags: cloneMap))],
  );
}

class TagsSetLoading implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [_updateTagState((tagState) => tagState.copyWith(isLoading: true))],
    );
  }
}

class TagsSetLoaded implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [_updateTagState((tagState) => tagState.copyWith(isLoading: false))],
    );
  }
}

class TagsSetTags implements AppAction {
  final Iterable<Tag>? tagList;

  TagsSetTags({this.tagList});

  @override
  AppState updateState(AppState appState) {
    return _updateTags(appState, (tag) {
      tag.addEntries(
        tagList!.map(
          (tag) => MapEntry(tag.id!, tag),
        ),
      );
    });
  }
}
