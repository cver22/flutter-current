import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import '../../member/member_model/log_member_model/log_member.dart';
import '../../utils/db_consts.dart';
import 'log_entity.dart';

@immutable
class Log extends Equatable {
  //TODO need default to last or home currency for entries in this log
  //TODO each log to have its own settings

  Log({
    required this.uid,
    this.id,
    this.name,
    this.currency,
    this.categories = const [],
    this.subcategories = const [],
    this.archive = false,
    this.defaultCategory = NO_CATEGORY,
    this.logMembers = const {},
  });

  final String uid;
  final String? id;
  final String? name;
  final String? currency;
  final bool archive;
  final String defaultCategory;
  final List<AppCategory> categories;
  final List<AppCategory> subcategories;
  final Map<String, LogMember> logMembers;

  @override
  List<Object?> get props => [
        uid,
        id,
        name,
        currency,
        categories,
        subcategories,
        archive,
        defaultCategory,
        logMembers,
      ];

  @override
  String toString() {
    return 'Log {$UID: $uid, $ID: $id, $LOG_NAME: $name, currency: $currency, $CATEGORIES: $categories,  '
        '$SUBCATEGORIES: $subcategories, $ARCHIVE: $archive, $DEFAULT_CATEGORY: $defaultCategory, members: $logMembers}';
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
      currency: entity.currency ?? 'CAD',
      categories: categories,
      subcategories: subcategories,
      archive: entity.archive,
      defaultCategory: entity.defaultCategory,
      logMembers: logMemberHashMap,
    );
  }

  Log copyWith({
    String? uid,
    String? id,
    String? name,
    String? currency,
    bool? archive,
    String? defaultCategory,
    List<AppCategory>? categories,
    List<AppCategory>? subcategories,
    Map<String, LogMember>? logMembers,
  }) {
    if ((uid == null || identical(uid, this.uid)) &&
        (id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (currency == null || identical(currency, this.currency)) &&
        (archive == null || identical(archive, this.archive)) &&
        (defaultCategory == null ||
            identical(defaultCategory, this.defaultCategory)) &&
        (categories == null || identical(categories, this.categories)) &&
        (subcategories == null ||
            identical(subcategories, this.subcategories)) &&
        (logMembers == null || identical(logMembers, this.logMembers))) {
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
    );
  }
}
