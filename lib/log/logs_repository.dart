import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth_user/models/app_user.dart';
import '../utils/db_consts.dart';
import 'log_model/log.dart';
import 'log_model/log_entity.dart';

abstract class LogsRepository {
  Future<void> addNewLog(Log log);

  Stream<List<Log>> loadLogs(AppUser user);

  Future<void> updateLog(Log? log);

  void deleteLog(Log? log);
}

class FirebaseLogsRepository implements LogsRepository {
  final logsCollection = FirebaseFirestore.instance.collection(LOG_COLLECTION).withConverter(fromFirestore: (snapshot, _)
  => LogEntity.fromJson(snapshot.data()!, snapshot.id),
    toFirestore: (logEntity, _) => logEntity.toJson(),);

  @override
  Future<void> addNewLog(Log log) {
    return logsCollection.doc(log.id).set(log.toEntity());
  }

  @override
  Stream<List<Log>> loadLogs(AppUser user) {
    return logsCollection
        .where(MEMBER_LIST, arrayContains: user.id)
        .snapshots()
        .map((snapshot) {
      var snapshots = snapshot.docs
          .map((doc) => Log.fromEntity(doc.data()))
          .toList();

      return snapshots;
    });
  }

  @override
  Future<void> updateLog(Log? update) {
    return logsCollection.doc(update!.id).update(update.toEntity().toJson());
  }

  @override
  void deleteLog(Log? log) {
    logsCollection.doc(log!.id).delete();
  }
}
