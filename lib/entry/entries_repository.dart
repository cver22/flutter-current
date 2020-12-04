import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/entry/entry_model/my_entry_entity.dart';
import 'package:expenses/utils/db_consts.dart';

abstract class EntriesRepository {
  Future<void> addNewEntry(MyEntry entry);

  Stream<List<MyEntry>> loadEntries(User user);

  Future<void> updateEntry(MyEntry entry);

  void deleteEntry(MyEntry entry);
}

class FirebaseEntriesRepository implements EntriesRepository {
  final entriesCollection = Firestore.instance.collection('entries');

  @override
  Future<void> addNewEntry(MyEntry entry) {
    return entriesCollection.add(entry.toEntity().toDocument());
  }

  //TODO need to filter by contains UID
  @override
  Stream<List<MyEntry>> loadEntries(User user) {
    return entriesCollection.snapshots().map((snapshot) {
      return snapshot.documents.map((doc) => MyEntry.fromEntity(MyEntryEntity.fromSnapshot(doc))).toList();
    });
  }

  @override
  Future<void> updateEntry(MyEntry update) {
    return entriesCollection.document(update.id).updateData(update.toEntity().toDocument());
  }

  @override
  void deleteEntry(MyEntry entry) {
    entriesCollection.document(entry.id).delete();
  }
}
