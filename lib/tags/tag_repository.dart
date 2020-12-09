import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tag_model/tag_entity.dart';
import 'package:expenses/utils/db_consts.dart';

abstract class TagRepository {
  Future<void> addNewTag(Tag tag);

  Stream<List<Tag>> loadTags(User user);

  Future<void> updateTag(Tag tag);

  void deleteTag(Tag tag);
}

class FirebaseTagRepository implements TagRepository {
  final tagCollection = Firestore.instance.collection(TAG_COLLECTION);

  @override
  Future<void> addNewTag(Tag tag) {
    return tagCollection.add(tag.toEntity().toJson());
  }

  //TODO need to filter by UID for groups
  @override
  Stream<List<Tag>> loadTags(User user) {
    return tagCollection.where(UID, isEqualTo: user.id).snapshots().map((snapshot) {
      var snapshots = snapshot.documents.map((doc) => Tag.fromEntity(TagEntity.fromSnapshot(doc))).toList();

      return snapshots;
    });
  }

  @override
  Future<void> updateTag(Tag tag) {
    return tagCollection.document(tag.id).updateData(tag.toEntity().toJson());
  }

  @override
  void deleteTag(Tag tag) {
    tagCollection.document(tag.id).delete();
  }
}
