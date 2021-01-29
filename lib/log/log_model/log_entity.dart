import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_category/my_category_entity.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/member/member_model/log_member_model/log_member_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';

@immutable
class LogEntity extends Equatable {
  final String uid;
  final String id;
  final String name;
  final String currency;
  final bool archive;
  final String defaultCategory;
  final Map<String, MyCategory> categories;
  final Map<String, MyCategory> subcategories;
  final Map<String, LogMember> logMembers;
  final List<String> memberList;
  final int order;

  const LogEntity(
      {this.uid,
      this.id,
      this.name,
      this.currency,
      this.categories,
      this.subcategories,
      this.archive,
      this.defaultCategory,
      this.logMembers,
      this.memberList,
      this.order});

  @override
  List<Object> get props =>
      [uid, id, name, currency, categories, subcategories, archive, defaultCategory, logMembers, memberList, order];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $name, currency: $currency, categories: $categories, '
        '$SUBCATEGORIES: $subcategories, archive: $archive, defaultCategory: $defaultCategory, members: $logMembers, '
        'memberList: $memberList, order: $order}';
  }

  static LogEntity fromSnapshot(DocumentSnapshot snap) {
    return LogEntity(
      uid: snap.data[UID],
      id: snap.documentID,
      name: snap.data[LOG_NAME],
      currency: snap.data[CURRENCY_NAME],
      categories: (snap.data[CATEGORIES] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, MyCategory.fromEntity(MyCategoryEntity.fromJson(value)))),
      subcategories: (snap.data[SUBCATEGORIES] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, MyCategory.fromEntity(MyCategoryEntity.fromJson(value)))),
      archive: snap.data[ARCHIVE],
      defaultCategory: snap.data[DEFAULT_CATEGORY],
      logMembers: (snap.data[MEMBERS] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, LogMember.fromEntity(LogMemberEntity.fromJson(value)))),
      order: snap.data[ORDER],
    );
  }

  Map<String, Object> toDocument() {
    return {
      UID: uid,
      LOG_NAME: name,
      CURRENCY_NAME: currency,
      CATEGORIES: categories.map((key, value) => MapEntry(key, value.toEntity().toJson())),
      SUBCATEGORIES: subcategories.map((key, value) => MapEntry(key, value.toEntity().toJson())),
      ARCHIVE: archive,
      DEFAULT_CATEGORY: defaultCategory,
      MEMBERS: logMembers.map((key, value) => MapEntry(key, value.toEntity().toJson())),
      MEMBER_LIST: memberList,
      ORDER: order
    };
  }
}
