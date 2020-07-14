import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/env.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/entry/my_entry_entity.dart';
import 'package:expenses/models/user.dart';
import 'package:expenses/store/actions/actions.dart';

abstract class EntriesRepository {
  Future<void> addNewEntry(MyEntry entry);

  Future<void> deleteEntry(User user, MyEntry entry);

  Stream<List<MyEntry>> loadEntries(User user);

  Future<void> updateEntry(User user, MyEntry entry);
}

class FirebaseEntriesRepository implements EntriesRepository {
  final entriesCollection = Firestore.instance.collection('entries');

  @override
  Future<void> addNewEntry(MyEntry entry) {
    return entriesCollection.add(entry.toEntity().toDocument());
  }

  //could be deprecated as it is essentially the same function as updateEntry
  @override
  Future<void> deleteEntry(User user, MyEntry inActive) async {
    return entriesCollection
        .document(inActive.id)
        .updateData(inActive.toEntity().toDocument());
  }

  //TODO need to filter by contains UID
  @override
  Stream<List<MyEntry>> loadEntries(User user) {
    return entriesCollection.snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => MyEntry.fromEntity(MyEntryEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Future<void> updateEntry(User user, MyEntry update) {
    return entriesCollection
        .document(update.id)
        .updateData(update.toEntity().toDocument());
  }
}
