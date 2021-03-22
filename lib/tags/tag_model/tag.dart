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
  final List<String> memberList;

  Tag(
      {this.logId,
      this.id,
      this.name = '',
      this.tagLogFrequency = 0,
      this.tagCategoryFrequency = const {},
      this.memberList = const []});

  Tag copyWith(
      {String logId,
      String id,
      String name,
      int tagLogFrequency,
      Map<String, int> tagCategoryFrequency,
      List<String> memberList}) {
    return Tag(
      logId: logId ?? this.logId,
      id: id ?? this.id,
      name: name ?? this.name,
      tagLogFrequency: tagLogFrequency ?? this.tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency ?? this.tagCategoryFrequency,
      memberList: memberList ?? this.memberList,
    );
  }

  @override
  String toString() {
    return 'Tag {$LOG_ID: $logId $ID: $id, $NAME: $name, $TAG_LOG_FREQUENCY: $tagLogFrequency, $TAG_CATEGORY_FREQUENCY: $tagCategoryFrequency, $MEMBER_LIST: $memberList}';
  }

  @override
  List<Object> get props =>
      [logId, id, name, tagLogFrequency, tagCategoryFrequency, memberList];

  TagEntity toEntity() {
    return TagEntity(
      logId: logId,
      id: id,
      name: name,
      tagLogFrequency: tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency,
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
