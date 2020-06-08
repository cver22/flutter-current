import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/log/log_entity.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:flutter/foundation.dart';

class Log extends Equatable {
  //TODO log keeps track of who owes who how much "debt map"?

  Log(
      {@required this.uid,
      this.id,
      @required this.logName,
      @required this.currency,
      this.categories,
      this.subcategories,
      this.active = true,
      this.members});

  final String uid;
  final String id;
  final String logName;
  final String currency;
  final bool active;
  final List<MyCategory> categories;
  final List<MySubcategory> subcategories;
  final Map<String, dynamic> members;

  Log copyWith({
    String uid,
    String id,
    String logName,
    String currency,
    bool active,
    List<MyCategory> categories,
    List<MySubcategory> subcategories,
    Map<String, dynamic> members,
  }) {
    return Log(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      logName: logName ?? this.logName,
      currency: currency ?? this.currency,
      active: active ?? this.active,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      members: members ?? this.members,
    );
  }

  @override
  List<Object> get props =>
      [uid, id, logName, currency, categories, subcategories, active, members];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $logName, currency: $currency, categories: $categories,  $SUBCATEGORIES: $subcategories, active: $active, members: $members}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Log &&
          runtimeType == other.runtimeType &&
          logName == other.logName &&
          currency == other.currency &&
          categories == other.categories &&
          subcategories == other.subcategories &&
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
        categories: Map<String,MyCategory>.fromIterable(categories,
            key: (e) => categories.indexOf(e).toString(), value: (e) => e),
        subcategories: Map<String,MySubcategory>.fromIterable(subcategories,
            key: (e) => subcategories.indexOf(e).toString(), value: (e) => e),
        active: active,
        members: members);
  }

  static Log fromEntity(LogEntity entity) {
    return Log(
      uid: entity.uid,
      id: entity.id,
      logName: entity.logName,
      currency: entity.currency,
      categories: entity.categories.entries.map((e) => e.value).toList(),
      subcategories: entity.subcategories.entries.map((e) => e.value).toList(),
      active: entity.active,
      members: entity.members,
    );
  }
}
