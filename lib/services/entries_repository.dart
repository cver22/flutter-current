
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/entry/my_entry_entity.dart';
import 'package:expenses/models/user/user.dart';

abstract class EntriesRepository {
  Future<void> addNewEntry(MyEntry entry);

  Future<void> deleteEntry(MyEntry entry);

  Stream<List<MyEntry>> loadEntries();

  Future<void> updateEntry(MyEntry entry);
}

class FirebaseEntriesRepository implements EntriesRepository {
  final User user;

  FirebaseEntriesRepository({this.user});

  final entriesCollection = Firestore.instance.collection('entries');

  @override
  Future<void> addNewEntry(MyEntry entry) {
    return entriesCollection.add(entry.toEntity().toDocument());
  }

  @override
  Future<void> deleteEntry(MyEntry inActive) async {
    return entriesCollection
        .document(inActive.id)
        .updateData(inActive.toEntity().toDocument());
  }

  //TODO need to filter by contains UID
  @override
  Stream<List<MyEntry>> loadEntries() {
    return entriesCollection.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => MyEntry.fromEntity(MyEntryEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Future<void> updateEntry(MyEntry update) {
    return entriesCollection
        .document(update.id)
        .updateData(update.toEntity().toDocument());
  }
}