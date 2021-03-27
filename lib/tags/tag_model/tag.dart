import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../utils/db_consts.dart';
import 'tag_entity.dart';

@immutable
class Tag extends Equatable {
  final String logId;
  final String id;
  final String name;
  final int tagLogFrequency;
  final Map<String, int> tagCategoryFrequency;
  final Map<String, int> tagSubcategoryFrequency;
  final List<String> memberList;

  Tag(
      {this.logId,
      this.id,
      this.name = '',
      this.tagLogFrequency = 0,
      @required this.tagCategoryFrequency,
      @required this.tagSubcategoryFrequency,
      this.memberList = const []});

  @override
  String toString() {
    return 'Tag {$LOG_ID: $logId $ID: $id, $NAME: $name, $TAG_LOG_FREQUENCY: $tagLogFrequency, $TAG_CATEGORY_FREQUENCY: $tagCategoryFrequency, $TAG_SUBCATEGORY_FREQUENCY: $tagSubcategoryFrequency, $MEMBER_LIST: $memberList}';
  }

  @override
  List<Object> get props => [logId, id, name, tagLogFrequency, tagCategoryFrequency, memberList];

  TagEntity toEntity() {
    return TagEntity(
      logId: logId,
      id: id,
      name: name,
      tagLogFrequency: tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency,
      tagSubcategoryFrequency: tagSubcategoryFrequency,
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
      tagSubcategoryFrequency: entity?.tagSubcategoryFrequency ?? <String, int>{},
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

  Tag copyWith({
    String logId,
    String id,
    String name,
    int tagLogFrequency,
    Map<String, int> tagCategoryFrequency,
    Map<String, int> tagSubcategoryFrequency,
    List<String> memberList,
  }) {
    if ((logId == null || identical(logId, this.logId)) &&
        (id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (tagLogFrequency == null || identical(tagLogFrequency, this.tagLogFrequency)) &&
        (tagCategoryFrequency == null || identical(tagCategoryFrequency, this.tagCategoryFrequency)) &&
        (tagSubcategoryFrequency == null || identical(tagSubcategoryFrequency, this.tagSubcategoryFrequency)) &&
        (memberList == null || identical(memberList, this.memberList))) {
      return this;
    }

    return new Tag(
      logId: logId ?? this.logId,
      id: id ?? this.id,
      name: name ?? this.name,
      tagLogFrequency: tagLogFrequency ?? this.tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency ?? this.tagCategoryFrequency,
      tagSubcategoryFrequency: tagSubcategoryFrequency ?? this.tagSubcategoryFrequency,
      memberList: memberList ?? this.memberList,
    );
  }
}
