import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/categories.dart';
import 'package:expenses/models/log/log_entity.dart';
import 'package:flutter/foundation.dart';

class Log extends Equatable {
  //TODO log keeps track of who owes who how much "debt map"?

  Log(
      {@required this.uid,
      this.id,
      @required this.logName,
      @required this.currency,
      this.categories,
      this.active = true,
      this.members});

  final String uid;
  final String id;
  final String logName;
  final String currency;
  final Categories categories;
  final bool active;
  final Map<String, dynamic> members;

  Log copyWith(
      {String uid,
      String id,
      String logName,
      String currency,
      Categories categories,
      bool active,
      Map<String, dynamic> members}) {
    return Log(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      logName: logName ?? this.logName,
      currency: currency ?? this.currency,
      categories: categories ?? this.categories,
      active: active ?? this.active,
      members: members ?? this.members,
    );
  }

  @override
  List<Object> get props =>
      [uid, id, logName, currency, categories, active, members];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $logName, currency: $currency, categories: $categories, active: $active, members: $members}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Log &&
          runtimeType == other.runtimeType &&
          logName == other.logName &&
          currency == other.currency &&
          categories == other.categories &&
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
        categories: categories,
        active: active,
        members: members);
  }

  static Log fromEntity(LogEntity entity) {
    return Log(
      uid: entity.uid,
      id: entity.id,
      logName: entity.logName,
      currency: entity.currency,
      categories: entity.categories,
      active: entity.active,
      members: entity.members,
    );
  }
}
