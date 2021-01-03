import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'tag_entity.g.dart';

@immutable
@JsonSerializable()
class TagEntity extends Equatable {
  final String uid;
  final String logId;
  final String id;
  final String name;
  final int tagLogFrequency;
  final Map<String, int> tagCategoryFrequency;
  final List<String> memberList;

  const TagEntity({this.uid, this.logId, this.id, this.name, this.tagLogFrequency, this.tagCategoryFrequency, this.memberList});

  @override
  List<Object> get props => [uid, logId, id, name, tagLogFrequency, tagCategoryFrequency, memberList];

  @override
  String toString() {
    return 'MyTagEntity {$UID: $uid, $LOG_ID: $logId, $ID: $id, $NAME: $name, $TAG_LOG_FREQUENCY: $tagLogFrequency, '
        '$TAG_CATEGORY_FREQUENCY: $tagCategoryFrequency, $MEMBER_LIST: $memberList}';
  }

  factory TagEntity.fromJson(Map<String, dynamic> json) => _$TagEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TagEntityToJson(this);

  static TagEntity fromSnapshot(DocumentSnapshot snap) {
    return TagEntity(
      uid: snap.data[UID],
      logId: snap.data[LOG_ID],
      id: snap.documentID,
      name: snap.data[NAME],
      tagLogFrequency: snap.data[TAG_LOG_FREQUENCY],
      tagCategoryFrequency:
          (snap.data[TAG_CATEGORY_FREQUENCY] as Map<String, dynamic>)?.map((key, value) => MapEntry(key, value)),
      memberList: snap.data[MEMBER_LIST]
    );
  }
}
