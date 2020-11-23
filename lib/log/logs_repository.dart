import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/log_entity.dart';
import 'package:expenses/utils/db_consts.dart';

abstract class LogsRepository {
  Future<void> addNewLog(User user, Log log);

  Stream<List<Log>> loadLogs(User user);

  Future<void> updateLog(User user, Log log);

  //void refresh(User user);

  void dispose();
}

class FirebaseLogsRepository implements LogsRepository {
  final logsCollection = Firestore.instance.collection('logs');
  final _loadedData = StreamController<List<Log>>();
  final _cache = List<Log>();
  StreamSubscription<QuerySnapshot> _streamSub;

  @override
  Future<void> addNewLog(User user, Log log) {
    return logsCollection.add(log.toEntity().toDocument());
  }

  /*@override
  void refresh(User user) {
    if (_streamSub != null) {
      _streamSub.cancel();
    }

    if (logsCollection != null) {
      _streamSub =
          logsCollection.where(UID, isEqualTo: user.id).where(ACTIVE, isEqualTo: true).snapshots().listen((query) {
        _cache.clear();
        query.documents.forEach((log) {
          _cache.add(Log.fromEntity(LogEntity.fromSnapshot(log)));
        });
        _cache.forEach((element) {print('log name from snapshot ${element.logName}');});

        _loadedData.add(_cache);
      });
    }
  }*/

  /*@override
  Stream<List<Log>> loadLogs(User user) {
    refresh(user);
    return _loadedData.stream;
  }*/

  //TODO need to filter by UID for groups
  @override
  Stream<List<Log>> loadLogs(User user) {

    return logsCollection.where(UID, isEqualTo: user.id).where(ACTIVE, isEqualTo: true).snapshots().map((snapshot) {
      var snapshots = snapshot.documents.map((doc) => Log.fromEntity(LogEntity.fromSnapshot(doc))).toList();
      snapshots.forEach((element) {print('log names from snapshots old method ${element.logName}');});
      return snapshots;
    });
  }

  @override
  Future<void> updateLog(User user, Log update) {
    return logsCollection.document(update.id).updateData(update.toEntity().toDocument());
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _loadedData?.close();
  }
}
