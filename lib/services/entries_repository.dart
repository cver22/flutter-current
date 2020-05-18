
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/models/entry/entry.dart';
import 'package:expenses/models/entry/entry_entity.dart';
import 'package:expenses/models/user/user.dart';

abstract class EntriesRepository {
  Future<void> addNewEntry(Entry entry);

  Future<void> deleteEntry(Entry entry);

  Stream<List<Entry>> loadEntries();

  Future<void> updateEntry(Entry entry);
}

class FirebaseEntriesRepository implements EntriesRepository {
  final User user;

  FirebaseEntriesRepository({this.user});

  final entriesCollection = Firestore.instance.collection('entries');

  @override
  Future<void> addNewEntry(Entry entry) {
    return entriesCollection.add(entry.toEntity().toDocument());
  }

  @override
  Future<void> deleteEntry(Entry inActive) async {
    return entriesCollection
        .document(inActive.id)
        .updateData(inActive.toEntity().toDocument());
  }

  //TODO need to filter by contains UID
  @override
  Stream<List<Entry>> loadEntries() {
    return entriesCollection.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => Entry.fromEntity(EntryEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Future<void> updateEntry(Entry update) {
    return entriesCollection
        .document(update.id)
        .updateData(update.toEntity().toDocument());
  }
}