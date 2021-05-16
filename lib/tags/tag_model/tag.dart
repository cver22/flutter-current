import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../utils/db_consts.dart';
import 'tag_entity.dart';

@immutable
class Tag extends Equatable {
  final String? logId;
  final String? id;
  final String name;
  final int tagLogFrequency; //how often the tag is used in its parent log
  final Map<String, int> tagCategoryFrequency; //how often the tag is used for each category
  final Map<String, DateTime> tagCategoryLastUse; //when the tag was last used for the category
  final Map<String, int> tagSubcategoryFrequency; //how often the tag is used for each subcategory
  final Map<String, DateTime> tagSubcategoryLastUse; // when the tag was last used for the subcategory
  final List<String> memberList; //used for retrieval from database

  Tag({
    this.logId,
    this.id,
    this.name = '',
    this.tagLogFrequency = 0,
    this.tagCategoryFrequency = const <String, int>{},
    this.tagCategoryLastUse = const <String, DateTime>{},
    this.tagSubcategoryFrequency = const <String, int>{},
    this.tagSubcategoryLastUse = const <String, DateTime>{},
    this.memberList = const [],
  });

  Tag copyWith({
    String? logId,
    String? id,
    String? name,
    int? tagLogFrequency,
    Map<String, int>? tagCategoryFrequency,
    Map<String, DateTime>? tagCategoryLastUse,
    Map<String, int>? tagSubcategoryFrequency,
    Map<String, DateTime>? tagSubcategoryLastUse,
    List<String>? memberList,
  }) {
    if ((logId == null || identical(logId, this.logId)) &&
        (id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (tagLogFrequency == null || identical(tagLogFrequency, this.tagLogFrequency)) &&
        (tagCategoryFrequency == null || identical(tagCategoryFrequency, this.tagCategoryFrequency)) &&
        (tagCategoryLastUse == null || identical(tagCategoryLastUse, this.tagCategoryLastUse)) &&
        (tagSubcategoryFrequency == null || identical(tagSubcategoryFrequency, this.tagSubcategoryFrequency)) &&
        (tagSubcategoryLastUse == null || identical(tagSubcategoryLastUse, this.tagSubcategoryLastUse)) &&
        (memberList == null || identical(memberList, this.memberList))) {
      return this;
    }

    return new Tag(
      logId: logId ?? this.logId,
      id: id ?? this.id,
      name: name ?? this.name,
      tagLogFrequency: tagLogFrequency ?? this.tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency ?? this.tagCategoryFrequency,
      tagCategoryLastUse: tagCategoryLastUse ?? this.tagCategoryLastUse,
      tagSubcategoryFrequency: tagSubcategoryFrequency ?? this.tagSubcategoryFrequency,
      tagSubcategoryLastUse: tagSubcategoryLastUse ?? this.tagSubcategoryLastUse,
      memberList: memberList ?? this.memberList,
    );
  }

  @override
  String toString() {
    return 'Tag {$LOG_ID: $logId $ID: $id, $NAME: $name, $TAG_LOG_FREQUENCY: $tagLogFrequency, '
        '$TAG_CATEGORY_FREQUENCY: $tagCategoryFrequency, $TAG_CATEGORY_LAST_USE: $tagCategoryLastUse,'
        '$TAG_SUBCATEGORY_FREQUENCY: $tagSubcategoryFrequency, $TAG_SUBCATEGORY_LAST_USE: $tagSubcategoryLastUse'
        '$MEMBER_LIST: $memberList}';
  }

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

  TagEntity toEntity() {
    return TagEntity(
      logId: logId,
      id: id,
      name: name,
      tagLogFrequency: tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency,
      tagCategoryLastUse: tagCategoryLastUse,
      tagSubcategoryFrequency: tagSubcategoryFrequency,
      tagSubcategoryLastUse: tagSubcategoryLastUse,
      memberList: memberList,
    );
  }

  static Tag fromEntity(TagEntity entity) {
    return Tag(
      logId: entity.logId,
      id: entity.id,
      name: entity.name,
      tagLogFrequency: entity.tagLogFrequency,
      tagCategoryFrequency: entity.tagCategoryFrequency,
      tagCategoryLastUse: entity.tagCategoryLastUse,
      tagSubcategoryFrequency: entity.tagSubcategoryFrequency,
      tagSubcategoryLastUse: entity.tagSubcategoryLastUse,
      memberList: entity.memberList,
    );
  }

  Tag incrementTagLogFrequency() {
    return this.copyWith(tagLogFrequency: this.tagLogFrequency + 1);
  }

  Tag decrementTagLogFrequency() {
    if (this.tagLogFrequency >= 1) {
      return this.copyWith(tagLogFrequency: this.tagLogFrequency - 1);
    } else {
      return this;
    }
  }
}
