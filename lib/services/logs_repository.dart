import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/models/log/log_entity.dart';
import 'package:expenses/models/user/user.dart';
import 'package:expenses/res/db_consts.dart';

abstract class LogsRepository {
  Future<void> addNewLog(Log log);

  Future<void> deleteLog(Log log);

  Stream<List<Log>> loadLogs();

  Future<void> updateLog(Log log);
}

class FirebaseLogsRepository implements LogsRepository {
  final User user;

  FirebaseLogsRepository({this.user});

  final logsCollection = Firestore.instance.collection('logs');

  @override
  Future<void> addNewLog(Log log) {
    //adds uid to new logs
    //TODO move this to logsBloc so it can also handle when members are added?
    return logsCollection.add(log.copyWith(uid: user.id).toEntity().toDocument());
  }

  @override
  Future<void> deleteLog(Log inActive) async {
    return logsCollection
        .document(inActive.id)
        .updateData(inActive.toEntity().toDocument());
  }

  //TODO need to filter by UID
  @override
  Stream<List<Log>> loadLogs() {
    return logsCollection.where(UID, isEqualTo: user.id).snapshots().map((snapshot) {
      return snapshot.documents
          .map((doc) => Log.fromEntity(LogEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Future<void> updateLog(Log update) {
    return logsCollection
        .document(update.id)
        .updateData(update.toEntity().toDocument());
  }
}
