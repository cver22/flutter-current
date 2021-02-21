import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tag_model/tag_state.dart';

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

class SetTagsLoading implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateTagState(appState, (tagState) => tagState.copyWith(isLoading: true));
  }
}

class SetTagsLoaded implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateTagState(appState, (tagState) => tagState.copyWith(isLoading: false));
  }
}

class SetTags implements AppAction {
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
