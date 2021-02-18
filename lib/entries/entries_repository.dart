import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/entry/entry_model/app_entry_entity.dart';
import 'package:expenses/utils/db_consts.dart';

abstract class EntriesRepository {
  Future<void> addNewEntry(MyEntry entry);

  Stream<List<MyEntry>> loadEntries(User user);

  Future<void> updateEntry(MyEntry entry);

  Future<void> deleteEntry(MyEntry entry);

  Future<void> batchDeleteEntries({List<MyEntry> deletedEntries}) {}

  Future<void> batchUpdateEntries({List<MyEntry> updatedEntries}) {}
}

class FirebaseEntriesRepository implements EntriesRepository {
  Firestore db = Firestore.instance;
  final entriesCollection = Firestore.instance.collection(ENTRY_COLLECTION);

  @override
  Future<void> addNewEntry(MyEntry entry) {
    return db.collection(ENTRY_COLLECTION).document(entry.id).setData(entry.toEntity().toDocument());
  }

  //TODO need to filter by contains UID
  @override
  Stream<List<MyEntry>> loadEntries(User user) {
    return db.collection(ENTRY_COLLECTION).where(MEMBER_LIST, arrayContains: user.id).snapshots().map((snapshot) {
      // FirebaseStorageCalculator(documents: snapshot.documents).getDocumentSize(); used to estimate file sizes
      return snapshot.documents.map((doc) => MyEntry.fromEntity(MyEntryEntity.fromSnapshot(doc))).toList();
    });
  }

  @override
  Future<void> updateEntry(MyEntry update) {
    return db.collection(ENTRY_COLLECTION).document(update.id).updateData(update.toEntity().toDocument());
  }

  @override
  Future<void> deleteEntry(MyEntry entry) {
    return db.collection(ENTRY_COLLECTION).document(entry.id).delete();
  }

  @override
  Future<void> batchDeleteEntries({List<MyEntry> deletedEntries}) {
    WriteBatch batch = db.batch();

    deletedEntries.forEach((entry) {
      batch.delete(db.collection(ENTRY_COLLECTION).document(entry.id));
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchUpdateEntries({List<MyEntry> updatedEntries}) {
    WriteBatch batch = db.batch();

    updatedEntries.forEach((entry) {
      batch.updateData(db.collection(TAG_COLLECTION).document(entry.id), {entry.id: entry.toEntity().toDocument()});
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }
}
