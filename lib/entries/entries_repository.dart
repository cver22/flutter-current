import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth_user/models/app_user.dart';
import '../entry/entry_model/app_entry.dart';
import '../entry/entry_model/app_entry_entity.dart';
import '../utils/db_consts.dart';

abstract class EntriesRepository {
  Future<void> addNewEntry(AppEntry entry);

  Stream<List<AppEntry>> loadEntries(AppUser user);

  Future<void> updateEntry(AppEntry entry);

  Future<void> deleteEntry(AppEntry entry);

  Future<void> batchDeleteEntries({List<AppEntry> deletedEntries}) {}

  Future<void> batchUpdateEntries({List<AppEntry> updatedEntries}) {}
}

class FirebaseEntriesRepository implements EntriesRepository {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final entriesCollection =
      FirebaseFirestore.instance.collection(ENTRY_COLLECTION);

  @override
  Future<void> addNewEntry(AppEntry entry) {
    return db
        .collection(ENTRY_COLLECTION)
        .doc(entry.id)
        .set(entry.toEntity().toDocument());
  }

  //TODO need to filter by contains UID
  @override
  Stream<List<AppEntry>> loadEntries(AppUser user) {
    return db
        .collection(ENTRY_COLLECTION)
        .where(MEMBER_LIST, arrayContains: user.id)
        .snapshots()
        .map((snapshot) {
      // FirebaseStorageCalculator(documents: snapshot.documents).getDocumentSize(); used to estimate file sizes
      return snapshot.docs
          .map((doc) => AppEntry.fromEntity(MyEntryEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Future<void> updateEntry(AppEntry update) {
    return db
        .collection(ENTRY_COLLECTION)
        .doc(update.id)
        .update(update.toEntity().toDocument());
  }

  @override
  Future<void> deleteEntry(AppEntry entry) {
    return db.collection(ENTRY_COLLECTION).doc(entry.id).delete();
  }

  @override
  Future<void> batchDeleteEntries({List<AppEntry> deletedEntries}) {
    WriteBatch batch = db.batch();

    deletedEntries.forEach((entry) {
      batch.delete(db.collection(ENTRY_COLLECTION).doc(entry.id));
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchUpdateEntries({List<AppEntry> updatedEntries}) {
    WriteBatch batch = db.batch();

    updatedEntries.forEach((entry) {
      batch.update(db.collection(TAG_COLLECTION).doc(entry.id),
          {entry.id: entry.toEntity().toDocument()});
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }
}
