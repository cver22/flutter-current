import 'package:equatable/equatable.dart';
import 'package:expenses/tags/tag_model/tag_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:meta/meta.dart';

@immutable
class Tag extends Equatable {
  final String uid;
  final String logId;
  final String id;
  final String name;
  final int tagLogFrequency;
  final Map<String, int> tagCategoryFrequency;

  Tag({this.uid, this.logId, this.id, this.name, this.tagLogFrequency = 0, this.tagCategoryFrequency = const {}});

  Tag copyWith({String uid, String logId, String id, String name, int logFrequency, Map<String, int> tagCategoryFrequency}) {
    return Tag(
      uid: uid ?? this.uid,
      logId: logId ?? this.logId,
      id: id ?? this.id,
      name: name ?? this.name,
      tagLogFrequency: logFrequency ?? this.tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency ?? this.tagCategoryFrequency,
    );
  }

  @override
  String toString() {
    return 'Tag {$UID: $uid, $LOG_ID: $logId $ID: $id, $NAME: $name, $TAG_LOG_FREQUENCY: $tagLogFrequency, $TAG_CATEGORY_FREQUENCY: $tagCategoryFrequency}';
  }

  @override
  List<Object> get props => [uid, logId, id, name, tagLogFrequency, tagCategoryFrequency];

  TagEntity toEntity() {
    return TagEntity(
      uid: uid,
      logId: logId,
      id: id,
      name: name,
      tagLogFrequency: tagLogFrequency,
      tagCategoryFrequency: tagCategoryFrequency,
    );
  }

  static Tag fromEntity(TagEntity entity) {
    return Tag(
      uid: entity.uid,
      logId: entity.logId,
      id: entity.id,
      name: entity.name,
      tagLogFrequency: entity.tagLogFrequency,
      tagCategoryFrequency: entity.tagCategoryFrequency,
    );
  }

  Tag incrementTagLogFrequency() {

    return this.copyWith(logFrequency: this.tagLogFrequency + 1);
  }

  Tag decrementTagLogFrequency() {
    if (this.tagLogFrequency >= 1) {
      return this.copyWith(logFrequency: this.tagLogFrequency - 1);
    } else {
      return this;
    }
  }
}
