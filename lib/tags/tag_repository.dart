import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth_user/models/app_user.dart';
import '../utils/db_consts.dart';
import 'tag_model/tag.dart';
import 'tag_model/tag_entity.dart';

abstract class TagRepository {
  Future<void> addNewTag(Tag tag);

  Stream<List<Tag>> loadTags(AppUser user);

  Future<void> updateTag(Tag tag);

  Future<void> deleteTag(Tag tag);

  Future<void> batchUpdateTags({List<Tag> updatedTags}) {}

  Future<void> batchAddTags({List<Tag> addedTags}) {}

  Future<void> batchDeleteTags({List<Tag> deletedTags}) {}
}

class FirebaseTagRepository implements TagRepository {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Future<void> addNewTag(Tag tag) {
    return db.collection(TAG_COLLECTION).add(tag.toEntity().toJson());
  }

  //TODO need to filter by UID for groups
  @override
  Stream<List<Tag>> loadTags(AppUser user) {
    return db
        .collection(TAG_COLLECTION)
        .where(MEMBER_LIST, arrayContains: user.id)
        .snapshots()
        .map((snapshot) {
      var snapshots = snapshot.docs
          .map((doc) => Tag.fromEntity(TagEntity.fromSnapshot(doc)))
          .toList();

      return snapshots;
    });
  }

  @override
  Future<void> updateTag(Tag tag) {
    return db
        .collection(TAG_COLLECTION)
        .doc(tag.id)
        .update(tag.toEntity().toJson());
  }

  @override
  Future<void> deleteTag(Tag tag) {
    return db.collection(TAG_COLLECTION).doc(tag.id).delete();
  }

  @override
  Future<void> batchAddTags({List<Tag> addedTags}) {
    WriteBatch batch = db.batch();

    addedTags.forEach((tag) {
      batch.set(
          db.collection(TAG_COLLECTION).doc(tag.id), tag.toEntity().toJson());
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchUpdateTags({List<Tag> updatedTags}) {
    WriteBatch batch = db.batch();

    updatedTags.forEach((tag) {
      batch.update(
          db.collection(TAG_COLLECTION).doc(tag.id), tag.toEntity().toJson());
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchDeleteTags({List<Tag> deletedTags}) {
    WriteBatch batch = db.batch();

    deletedTags.forEach((tag) {
      batch.delete(db.collection(TAG_COLLECTION).doc(tag.id));
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }
}
