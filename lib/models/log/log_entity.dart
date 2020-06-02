import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory_entity.dart';
import 'package:expenses/res/db_consts.dart';

class LogEntity extends Equatable {
  final String uid;
  final String id;
  final String logName;
  final String currency;
  final bool active;
  final Map<String, MyCategory> categories;
  final Map<String, MySubcategory> subcategories;
  final Map<String, dynamic> members;

  const LogEntity(
      {this.uid,
      this.id,
      this.logName,
      this.currency,
      this.categories,
      this.subcategories,
      this.active,
      this.members});

  //DEPRECATED
  //for use in other database types
  /*Map<String, Object> toJson() {
    return {
      UID: uid,
      ID: id,
      LOG_NAME: logName,
      CURRENCY_NAME: currency,
      ACTIVE: active,
      MEMBER_ROLES_MAP: members,
    };
  }*/

  @override
  List<Object> get props =>
      [uid, id, logName, currency, categories, subcategories, active, members];

  @override
  String toString() {
    return 'Log {uid: $uid, id: $id, logName: $logName, currency: $currency, categories: $categories, $SUBCATEGORIES: $subcategories, ctive: $active, members: $members}';
  }

  //DEPRECATED
  //for use in other database types
  /*static LogEntity fromJson(Map<String, Object> json) {
    return LogEntity(
      uid: json[UID] as String,
      id: json[ID] as String,
      logName: json[LOG_NAME] as String,
      currency: json[CURRENCY_NAME] as String,
      active: json[ACTIVE] as bool,
      members: json[MEMBER_ROLES_MAP] as Map<String, dynamic>,
    );
  }*/

  static LogEntity fromSnapshot(DocumentSnapshot snap) {

    return LogEntity(
      uid: snap.data[UID],
      id: snap.documentID,
      logName: snap.data[LOG_NAME],
      currency: snap.data[CURRENCY_NAME],
      //TODO subcategories
      categories: (snap.data[CATEGORIES] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
              key, MyCategory.fromEntity(MyCategoryEntity.fromJson(value)))),
      subcategories: (snap.data[SUBCATEGORIES] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
              key, MySubcategory.fromEntity(MySubcategoryEntity.fromJson(value)))),
      active: snap.data[ACTIVE],
      members: snap.data[MEMBER_ROLES_MAP],
    );
  }

  Map<String, Object> toDocument() {
    return {
      UID: uid,
      LOG_NAME: logName,
      CURRENCY_NAME: currency,
      CATEGORIES: categories
          .map((key, value) => MapEntry(key, value.toEntity().toJson())),
      SUBCATEGORIES: subcategories
          .map((key, value) => MapEntry(key, value.toEntity().toJson())),
      ACTIVE: active,
      MEMBER_ROLES_MAP: members,
    };
  }
}
