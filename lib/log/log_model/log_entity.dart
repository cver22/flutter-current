import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_category/my_category_entity.dart';
import 'package:expenses/categories/categories_model/my_subcategory/my_subcategory.dart';
import 'package:expenses/categories/categories_model/my_subcategory/my_subcategory_entity.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/member/member_model/log_member_model/log_member_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';

@immutable
class LogEntity extends Equatable {
  final String uid;
  final String id;
  final String logName;
  final String currency;
  final bool archive;
  final String defaultCategory;
  final Map<String, MyCategory> categories;
  final Map<String, MySubcategory> subcategories;
  final Map<String, LogMember> logMembers;
  final List<String> memberList;

  const LogEntity(
      {this.uid,
      this.id,
      this.logName,
      this.currency,
      this.categories,
      this.subcategories,
      this.archive,
      this.defaultCategory,
      this.logMembers,
      this.memberList});

  @override
  List<Object> get props =>
      [uid, id, logName, currency, categories, subcategories, archive, defaultCategory, logMembers, memberList];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $logName, currency: $currency, categories: $categories, '
        '$SUBCATEGORIES: $subcategories, archive: $archive, defaultCategory: $defaultCategory, members: $logMembers, memberList: $memberList}';
  }

  static LogEntity fromSnapshot(DocumentSnapshot snap) {
    return LogEntity(
      uid: snap.data[UID],
      id: snap.documentID,
      logName: snap.data[LOG_NAME],
      currency: snap.data[CURRENCY_NAME],
      categories: (snap.data[CATEGORIES] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, MyCategory.fromEntity(MyCategoryEntity.fromJson(value)))),
      subcategories: (snap.data[SUBCATEGORIES] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, MySubcategory.fromEntity(MySubcategoryEntity.fromJson(value)))),
      archive: snap.data[ARCHIVE],
      defaultCategory: snap.data[DEFAULT_CATEGORY],
      logMembers: (snap.data[MEMBERS] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, LogMember.fromEntity(LogMemberEntity.fromJson(value)))),
    );
  }

  Map<String, Object> toDocument() {
    return {
      UID: uid,
      LOG_NAME: logName,
      CURRENCY_NAME: currency,
      CATEGORIES: categories.map((key, value) => MapEntry(key, value.toEntity().toJson())),
      SUBCATEGORIES: subcategories.map((key, value) => MapEntry(key, value.toEntity().toJson())),
      ARCHIVE: archive,
      DEFAULT_CATEGORY: defaultCategory,
      MEMBERS: logMembers.map((key, value) => MapEntry(key, value.toEntity().toJson())),
      MEMBER_LIST: memberList,
    };
  }
}
