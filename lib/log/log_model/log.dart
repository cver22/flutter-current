import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/app_category.dart';
import 'package:expenses/log/log_model/log_entity.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

@immutable
class Log extends Equatable {
  //TODO log keeps track of who owes who how much "debt map"?
  //TODO need default to last or home currency for entries in this log
  //TODO each log to have its own settings

  Log({
    this.uid,
    this.id,
    this.name,
    this.currency,
    this.categories,
    this.subcategories,
    this.archive = false,
    this.defaultCategory,
    this.logMembers,
    this.order,
  });

  final String uid;
  final String id;
  final String name;
  final String currency;
  final bool archive;
  final String defaultCategory;
  final List<AppCategory> categories;
  final List<AppCategory> subcategories;
  final Map<String, LogMember> logMembers;
  final int order;


  @override
  List<Object> get props => [uid, id, name, currency, categories, subcategories, archive, defaultCategory, logMembers, order];

  @override
  String toString() {
    return 'Log {$UID: $uid, $ID: $id, $LOG_NAME: $name, currency: $currency, $CATEGORIES: $categories,  '
        '$SUBCATEGORIES: $subcategories, $ARCHIVE: $archive, $DEFAULT_CATEGORY: $defaultCategory, members: $logMembers, order: $order}';
  }

  LogEntity toEntity() {
    return LogEntity(
      uid: uid,
      id: id,
      name: name,
      currency: currency,
      categories: Map<String, AppCategory>.fromIterable(categories,
          key: (e) => categories.indexOf(e).toString(), value: (e) => e),
      subcategories: Map<String, AppCategory>.fromIterable(subcategories,
          key: (e) => subcategories.indexOf(e).toString(), value: (e) => e),
      archive: archive,
      defaultCategory: defaultCategory,
      logMembers: logMembers,
      memberList: logMembers.keys.toList(),
      order: order,
    );
  }

  static Log fromEntity(LogEntity entity) {
//reorder the log members as per the user's preference prior to passing to the log
    LinkedHashMap<String, LogMember> logMemberHashMap = LinkedHashMap();
    List<AppCategory> categories = [];
    List<AppCategory> subcategories = [];

    for (int i = 0; i < entity.logMembers.length; i++) {
      entity.logMembers.forEach((key, value) {
        if (value.order == i) {
          logMemberHashMap.putIfAbsent(key, () => value);
        }
      });
    }

    //order categories as they should be
    for (int i = 0; i < entity.categories.length; i++) {
      entity.categories.forEach((key, category) {
        if (key == i.toString()) {
          categories.add(category);
        }
      });
    }

    //order subcategories as they should be
    for (int i = 0; i < entity.subcategories.length; i++) {
      entity.subcategories.forEach((key, subcategory) {
        if (key == i.toString()) {
          subcategories.add(subcategory);
        }
      });
    }


    return Log(
      uid: entity.uid,
      id: entity.id,
      name: entity.name,
      currency: entity.currency,
      categories: categories,
      subcategories: subcategories,
      archive: entity.archive,
      defaultCategory: entity.defaultCategory,
      logMembers: logMemberHashMap,
      order: entity.order,
    );
  }

  Log copyWith({
    String uid,
    String id,
    String name,
    String currency,
    bool archive,
    String defaultCategory,
    List<AppCategory> categories,
    List<AppCategory> subcategories,
    Map<String, LogMember> logMembers,
    int order,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (currency == null || identical(currency, this.currency)) &&
        (archive == null || identical(archive, this.archive)) &&
        (defaultCategory == null || identical(defaultCategory, this.defaultCategory)) &&
        (categories == null || identical(categories, this.categories)) &&
        (subcategories == null || identical(subcategories, this.subcategories)) &&
        (logMembers == null || identical(logMembers, this.logMembers)) &&
        (order == null || identical(order, this.order))) {
      return this;
    }

    return new Log(
      uid: uid ?? this.uid,
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      archive: archive ?? this.archive,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      logMembers: logMembers ?? this.logMembers,
      order: order ?? this.order,
    );
  }
}
