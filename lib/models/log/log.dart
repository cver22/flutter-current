import 'package:equatable/equatable.dart';
import 'package:expenses/models/log/log_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Log extends Equatable {
  //TODO need tracking for user categories, subcategories and their frequencies
  //TODO log keeps track of who owes who how much "debt map"?

  Log(
      {@required this.uid,
      this.id,
      @required this.logName,
      @required this.currency,
      this.active = true,
      this.members});

  final String uid;
  final String id;
  final String currency;
  final String logName;
  final bool active;
  final Map<String, dynamic> members;

  Log copyWith(
      {String uid,
      String id,
      String logName,
      String currency,
      bool active,
      Map<String, dynamic> members}) {
    return Log(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      logName: logName ?? this.logName,
      currency: currency ?? this.currency,
      active: active ?? this.active,
      members: members ?? this.members,
    );
  }

  @override
  List<Object> get props =>
      [uid, id, logName, currency, active, members];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $logName, currency: $currency, active: $active, members: $members}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Log &&
          runtimeType == other.runtimeType &&
          logName == other.logName &&
          currency == other.currency &&
          members == other.members &&
          id == other.id &&
          uid == other.uid &&
          active == other.active;

  LogEntity toEntity() {
    return LogEntity(
        uid: uid,
        id: id,
        logName: logName,
        currency: currency,
        active: active,
        members: members);
  }

  static Log fromEntity(LogEntity entity) {
    return Log(
      uid: entity.uid,
      id: entity.id,
      logName: entity.logName,
      currency: entity.currency,
      active: entity.active,
      members: entity.members,
    );
  }
}
