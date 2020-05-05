import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/res/db_consts.dart';

class LogEntity extends Equatable {
  final String uid;
  final String id;
  final String logName;
  final String currency;
  final bool active;
  final Map<String, dynamic> members;

  const LogEntity({this.uid, this.id, this.logName, this.currency, this.active, this.members});

  Map<String, Object> toJson() {
    return {
      UID: uid,
      ID: id,
      LOG_NAME: logName,
      CURRENCY_NAME: currency,
      ACTIVE: active,
      MEMBER_ROLES_MAP: members,
    };
  }

  @override
  List<Object> get props => [uid, id, logName, currency, active, members];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $logName, currency: $currency, active: $active, members: $members}';
  }

  static LogEntity fromJson(Map<String, Object> json) {
    return LogEntity(
      uid: json[UID] as String,
      id: json[ID] as String,
      logName: json[LOG_NAME] as String,
      currency: json[CURRENCY_NAME] as String,
      active: json[ACTIVE] as bool,
      members: json[MEMBER_ROLES_MAP] as Map<String, dynamic>,
    );
  }

  static LogEntity fromSnapshot(DocumentSnapshot snap) {
    return LogEntity(
      uid: snap.data[UID],
      id: snap.data[ID],
      logName: snap.data[LOG_NAME],
      currency: snap.data[CURRENCY_NAME],
      active: snap.data[ACTIVE],
      members: snap.data[MEMBER_ROLES_MAP],
    );
  }

  Map<String, Object> toDocument() {
    return {
      UID: uid,
      ID: id,
      LOG_NAME: logName,
      CURRENCY_NAME: currency,
      ACTIVE: active,
      MEMBER_ROLES_MAP: members,
    };
  }
}
