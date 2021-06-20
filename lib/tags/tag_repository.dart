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

  Future<void> batchAddTags({required List<Tag> addedTags}) async {}

  Future<void> batchDeleteTags({required List<Tag> deletedTags}) async {}

  Future<void> batchUpdateTags({required List<Tag> updatedTags}) async {}
}

class FirebaseTagRepository implements TagRepository {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late final logsCollection =  db.collection(TAG_COLLECTION).withConverter(fromFirestore: (snapshot, _)
  => TagEntity.fromJson(snapshot.data()!, snapshot.id),
    toFirestore: (logEntity, _) => logEntity.toJson(),);

  @override
  Future<void> addNewTag(Tag tag) {
    return logsCollection.add(tag.toEntity());
  }

  //TODO need to filter by UID for groups
  @override
  Stream<List<Tag>> loadTags(AppUser user) {
    return logsCollection
        .where(MEMBER_LIST, arrayContains: user.id)
        .snapshots()
        .map((snapshot) {
      var snapshots = snapshot.docs
          .map((doc) => Tag.fromEntity(doc.data()))
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
    return logsCollection.doc(tag.id).delete();
  }

  @override
  Future<void> batchAddTags({required List<Tag> addedTags}) async {
    WriteBatch batch = db.batch();

    addedTags.forEach((tag) {
      batch.set(
          db.collection(TAG_COLLECTION).doc(tag.id), tag.toEntity().toJson());
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchUpdateTags({required List<Tag> updatedTags}) async {
    WriteBatch batch = db.batch();

    updatedTags.forEach((tag) {
      batch.update(
          db.collection(TAG_COLLECTION).doc(tag.id), tag.toEntity().toJson());
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchDeleteTags({required List<Tag> deletedTags}) async {
    WriteBatch batch = db.batch();

    deletedTags.forEach((tag) {
      batch.delete(db.collection(TAG_COLLECTION).doc(tag.id));
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }
}
