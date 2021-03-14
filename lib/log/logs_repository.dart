import 'dart:async';
import 'package:expenses/auth_user/models/app_user.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/log_entity.dart';
import 'package:expenses/utils/db_consts.dart';

abstract class LogsRepository {
  Future<void> addNewLog(Log log);

  Stream<List<Log>> loadLogs(AppUser user);

  Future<void> updateLog(Log log);

  void deleteLog(Log log);
}

class FirebaseLogsRepository implements LogsRepository {
  final logsCollection = Firestore.instance.collection(LOG_COLLECTION);

  @override
  Future<void> addNewLog(Log log) {
    return logsCollection.document(log.id).setData(log.toEntity().toDocument());
  }

  @override
  Stream<List<Log>> loadLogs(AppUser user) {
    return logsCollection.where(MEMBER_LIST, arrayContains: user.id).snapshots().map((snapshot) {
      var snapshots = snapshot.documents.map((doc) => Log.fromEntity(LogEntity.fromSnapshot(doc))).toList();

      return snapshots;
    });
  }

  @override
  Future<void> updateLog(Log update) {
    return logsCollection.document(update.id).updateData(update.toEntity().toDocument());
  }

  @override
  void deleteLog(Log log) {
    logsCollection.document(log.id).delete();
  }
}
