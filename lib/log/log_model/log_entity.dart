import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import '../../categories/categories_model/app_category/app_category_entity.dart';
import '../../member/member_model/log_member_model/log_member.dart';
import '../../member/member_model/log_member_model/log_member_entity.dart';
import '../../utils/db_consts.dart';

@immutable
class LogEntity extends Equatable {
  final String uid;
  final String? id;
  final String name;
  final String? currency;
  final bool archive;
  final String defaultCategory;
  final Map<String, AppCategory> categories;
  final Map<String, AppCategory> subcategories;
  final Map<String, LogMember> logMembers;
  final List<String> memberList;


  const LogEntity({
    required this.uid,
    this.id,
    this.name ='',
    required this.currency,
    this.categories = const {},
    this.subcategories = const {},
    this.archive = false,
    this.defaultCategory = NO_CATEGORY,
    this.logMembers = const {},
    this.memberList = const [],
  });


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
        memberList,
      ];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $name, currency: $currency, categories: $categories, '
        '$SUBCATEGORIES: $subcategories, archive: $archive, defaultCategory: $defaultCategory, members: $logMembers, '
        'memberList: $memberList}';
  }

  static LogEntity fromJson(Map<String, Object?> json, String id) {
    return LogEntity(
      uid: json[UID]! as String,
      id: id,
      name: json[LOG_NAME]! as String,
      currency: json[CURRENCY_NAME]! as String,
      categories: (json[CATEGORIES]! as LinkedHashMap<String, dynamic>)
          .map((key, value) => MapEntry(
              key, AppCategory.fromEntity(AppCategoryEntity.fromJson(value)))),
      subcategories: (json[SUBCATEGORIES]!
              as LinkedHashMap<String, dynamic>)
          .map((key, value) => MapEntry(
              key, AppCategory.fromEntity(AppCategoryEntity.fromJson(value)))),
      archive: json[ARCHIVE] as bool,
      defaultCategory: json[DEFAULT_CATEGORY] as String? ?? NO_CATEGORY,
      logMembers: (json[MEMBERS] as Map<String, dynamic>).map((key,
              value) =>
          MapEntry(key, LogMember.fromEntity(LogMemberEntity.fromJson(value)))),
    );
  }

  Map<String, Object?> toJson() {
    return {
      UID: uid,
      LOG_NAME: name,
      CURRENCY_NAME: currency,
      CATEGORIES: categories
          .map((key, value) => MapEntry(key, value.toEntity().toJson())),
      SUBCATEGORIES: subcategories
          .map((key, value) => MapEntry(key, value.toEntity().toJson())),
      ARCHIVE: archive,
      DEFAULT_CATEGORY: defaultCategory,
      MEMBERS: logMembers
          .map((key, value) => MapEntry(key, value.toEntity().toJson())),
      MEMBER_LIST: memberList,
    };
  }
}
