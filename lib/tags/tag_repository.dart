import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tag_model/tag_entity.dart';
import 'package:expenses/utils/db_consts.dart';

abstract class TagRepository {
  Future<void> addNewTag(Tag tag);

  Stream<List<Tag>> loadTags(User user);

  Future<void> updateTag(Tag tag);

  Future<void> deleteTag(Tag tag);

  Future<void> batchUpdateTags({List<Tag> updatedTags}) {}

  Future<void> batchAddTags({List<Tag> addedTags}) {}

  Future<void> batchDeleteTags({List<Tag> deletedTags}) {}
}

class FirebaseTagRepository implements TagRepository {
  Firestore db = Firestore.instance;

  @override
  Future<void> addNewTag(Tag tag) {
    return db.collection(TAG_COLLECTION).add(tag.toEntity().toJson());
  }

  //TODO need to filter by UID for groups
  @override
  Stream<List<Tag>> loadTags(User user) {
    return db.collection(TAG_COLLECTION).where(UID, isEqualTo: user.id).snapshots().map((snapshot) {
      var snapshots = snapshot.documents.map((doc) => Tag.fromEntity(TagEntity.fromSnapshot(doc))).toList();

      return snapshots;
    });
  }

  @override
  Future<void> updateTag(Tag tag) {
    return db.collection(TAG_COLLECTION).document(tag.id).updateData(tag.toEntity().toJson());
  }

  @override
  Future<void> deleteTag(Tag tag) {
    return db.collection(TAG_COLLECTION).document(tag.id).delete();
  }

  @override
  Future<void> batchAddTags({List<Tag> addedTags}) {
    WriteBatch batch = db.batch();

    addedTags.forEach((tag) {
      batch.setData(db.collection(TAG_COLLECTION).document(tag.id), tag.toEntity().toJson());
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchUpdateTags({List<Tag> updatedTags}) {
    WriteBatch batch = db.batch();

    updatedTags.forEach((tag) {
      batch.updateData(db.collection(TAG_COLLECTION).document(tag.id), {tag.id: tag.toEntity().toJson()});
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchDeleteTags({List<Tag> deletedTags}) {
    WriteBatch batch = db.batch();

    deletedTags.forEach((tag) {
      batch.delete(db.collection(TAG_COLLECTION).document(tag.id));
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }
}
