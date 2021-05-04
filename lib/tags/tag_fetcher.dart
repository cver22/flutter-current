import 'dart:async';

import 'package:meta/meta.dart';

import '../store/actions/tag_actions.dart';
import '../store/app_store.dart';
import 'tag_model/tag.dart';
import 'tag_repository.dart';

class TagFetcher {
  final AppStore _store;
  final TagRepository _tagRepository;
  StreamSubscription? _tagSubscription;

  TagFetcher({
    required AppStore store,
    required TagRepository tagRepository,
  })  : _store = store,
        _tagRepository = tagRepository;

  Future<void> loadTags() async {
    _store.dispatch(TagsSetLoading());
    _tagSubscription?.cancel();
    _tagSubscription =
        _tagRepository.loadTags(_store.state.authState.user.value).listen(
              (tags) => _store.dispatch(TagsSetTags(tagList: tags)),
            );
    _store.dispatch(TagsSetLoaded());
  }

  Future<void> addTag(Tag tag) async {
    try {
      _tagRepository.addNewTag(tag);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateTag(Tag tag) async {
    try {
      _tagRepository.updateTag(tag);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> batchAddUpdate(
      {required List<Tag> addedTags, required List<Tag> updatedTags}) async {
    if (addedTags.isNotEmpty) {
      try {
        _tagRepository.batchAddTags(addedTags: addedTags);
      } catch (e) {
        print(e.toString());
      }
    }

    if (updatedTags.isNotEmpty) {
      try {
        _tagRepository.batchUpdateTags(updatedTags: updatedTags);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  Future<void> deleteTag(Tag tag) async {
    try {
      _tagRepository.deleteTag(tag);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> batchDeleteTags({required List<Tag> deletedTags}) async {
    //log has been deleted, delete all associated tags

    if (deletedTags.isNotEmpty) {
      try {
        _tagRepository.batchDeleteTags(deletedTags: deletedTags);
      } catch (e) {
        print(e.toString());
      }
    }
  }

  //TODO where to close the subscription when exiting the app?
  Future<void> close() async {
    _tagSubscription?.cancel();
  }
}
