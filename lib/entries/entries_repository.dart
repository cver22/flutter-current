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

  Future<void> batchDeleteEntries({required List<String> deletedEntries}) async {}

  Future<void> batchUpdateEntries({required List<AppEntry> updatedEntries}) async {}
}

class FirebaseEntriesRepository implements EntriesRepository {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late final entriesCollection =
      db.collection(ENTRY_COLLECTION).withConverter(fromFirestore: (snapshot, _)
      => AppEntryEntity.fromJson(snapshot.data()!, snapshot.id),
        toFirestore: (appEntryEntity, _) => appEntryEntity.toJson(),);

  @override
  Future<void> addNewEntry(AppEntry entry) {
    return entriesCollection
        .doc(entry.id)
        .set(entry.toEntity());
  }

  //TODO need to filter by contains UID
  @override
  Stream<List<AppEntry>> loadEntries(AppUser user) {
    return entriesCollection
        .where(MEMBER_LIST, arrayContains: user.id)
        .snapshots()
        .map((snapshot) {
      // FirebaseStorageCalculator(documents: snapshot.documents).getDocumentSize(); used to estimate file sizes
      return snapshot.docs
          .map((doc) => AppEntry.fromEntity(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> updateEntry(AppEntry update) {
    return entriesCollection
        .doc(update.id)
        .update(update.toEntity().toJson());
  }

  @override
  Future<void> deleteEntry(AppEntry entry) {
    return entriesCollection.doc(entry.id).delete();
  }

  @override
  Future<void> batchDeleteEntries({required List<String> deletedEntries}) async {
    WriteBatch batch = db.batch();

    deletedEntries.forEach((entryId) {
      batch.delete(db.collection(ENTRY_COLLECTION).doc(entryId));
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }

  @override
  Future<void> batchUpdateEntries({required List<AppEntry> updatedEntries}) async {
    WriteBatch batch = db.batch();

    updatedEntries.forEach((entry) {
      batch.update(entriesCollection.doc(entry.id),
          {entry.id: entry.toEntity().toJson()});
    });

//TODO maybe add a whenComplete to this?
    return batch.commit();
  }
}
