import 'dart:async';

import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tag_repository.dart';
import 'package:meta/meta.dart';

class TagFetcher {
  final AppStore _store;
  final TagRepository _tagRepository;
  StreamSubscription _tagSubscription;

  TagFetcher({
    @required AppStore store,
    @required TagRepository tagRepository,
  })  : _store = store,
        _tagRepository = tagRepository;

  Future<void> loadTags() async {
    _store.dispatch(SetTagsLoading());
    _tagSubscription?.cancel();
    _tagSubscription = _tagRepository.loadTags(_store.state.authState.user.value).listen(
          (tags) => _store.dispatch(SetTags(tagList: tags)),
        );
    _store.dispatch(SetTagsLoaded());
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

  Future<void> batchAddUpdate({List<Tag> addedTags, List<Tag> updatedTags}) async {
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

  Future<void> batchDeleteTags({@required List<Tag> deletedTags}) async {
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
