import 'package:equatable/equatable.dart';
import '../../utils/db_consts.dart';

import 'package:meta/meta.dart';

@immutable
class TagEntity extends Equatable {
  final String? logId;
  final String? id;
  final String name;
  final int tagLogFrequency; //how often the tag is used in its parent log
  final Map<String, int> tagCategoryFrequency; //how often the tag is used for each category
  final Map<String, DateTime> tagCategoryLastUse; //when the tag was last used for the category
  final Map<String, int> tagSubcategoryFrequency; //how often the tag is used for each subcategory
  final Map<String, DateTime> tagSubcategoryLastUse; // when the tag was last used for the subcategory
  final List<String> memberList; //used for retrieval from database

  const TagEntity(
      {this.logId,
      this.id,
      this.name = '',
      this.tagLogFrequency = 0,
      this.tagCategoryFrequency = const {},
      this.tagCategoryLastUse = const {},
      this.tagSubcategoryFrequency = const {},
      this.tagSubcategoryLastUse = const {},
      this.memberList = const []});

  @override
  List<Object?> get props => [
        logId,
        id,
        name,
        tagLogFrequency,
        tagCategoryFrequency,
        tagCategoryLastUse,
        tagSubcategoryFrequency,
        tagSubcategoryLastUse,
        memberList,
      ];

  @override
  String toString() {
    return 'MyTagEntity {$LOG_ID: $logId $ID: $id, $NAME: $name, $TAG_LOG_FREQUENCY: $tagLogFrequency, '
        '$TAG_CATEGORY_FREQUENCY: $tagCategoryFrequency, $TAG_CATEGORY_LAST_USE: $tagCategoryLastUse,'
        '$TAG_SUBCATEGORY_FREQUENCY: $tagSubcategoryFrequency, $TAG_SUBCATEGORY_LAST_USE: $tagSubcategoryLastUse'
        '$MEMBER_LIST: $memberList}';
  }

  static TagEntity fromJson(Map<String, Object?> json, String id) {
    return TagEntity(
      logId: json[LOG_ID] as String,
      id: id,
      name: json[NAME] as String,
      tagLogFrequency: json[TAG_LOG_FREQUENCY] as int,
      tagCategoryFrequency:
          (json[TAG_CATEGORY_FREQUENCY] as Map<String, dynamic>).map((key, value) => MapEntry(key, value)),
      tagCategoryLastUse: (json[TAG_CATEGORY_LAST_USE] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value))) ??
          const {},
      tagSubcategoryFrequency:
          (json[TAG_SUBCATEGORY_FREQUENCY] as Map<String, dynamic>).map((key, value) => MapEntry(key, value)),
      tagSubcategoryLastUse: (json[TAG_SUBCATEGORY_LAST_USE] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value))) ??
          const {},
      memberList: List<String>.from(json[MEMBER_LIST] as List<dynamic>),
    );
  }

  Map<String, Object?> toJson() {
    return {
      LOG_ID: logId,
      ID: id,
      NAME: name,
      TAG_LOG_FREQUENCY: tagLogFrequency,
      TAG_CATEGORY_FREQUENCY: tagCategoryFrequency.map((key, value) => MapEntry(key, value)),
      TAG_CATEGORY_LAST_USE: tagCategoryLastUse.map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
      TAG_SUBCATEGORY_FREQUENCY: tagSubcategoryFrequency.map((key, value) => MapEntry(key, value)),
      TAG_SUBCATEGORY_LAST_USE: tagSubcategoryLastUse.map((key, value) => MapEntry(key, value.millisecondsSinceEpoch)),
      MEMBER_LIST: memberList.map((e) => e).toList(),
    };
  }
}
