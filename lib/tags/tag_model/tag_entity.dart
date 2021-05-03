import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../utils/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'tag_entity.g.dart';

@immutable
@JsonSerializable()
class TagEntity extends Equatable {
  final String logId;
  final String id;
  final String name;
  final int tagLogFrequency; //how often the tag is used in its parent log
  final Map<String, int> tagCategoryFrequency; //how often the tag is used for each category
  final Map<String, int> tagSubcategoryFrequency; //how often the tag is used for each subcategory
  final List<String> memberList; //used for retrieval from database


  const TagEntity(
      {this.logId = '',
        this.id = '',
        this.name = '',
        this.tagLogFrequency = 0,
        this.tagCategoryFrequency = const {},
        this.tagSubcategoryFrequency = const {},
        this.memberList = const []});


  @override
  List<Object?> get props => [logId, id, name, tagLogFrequency, tagCategoryFrequency, tagSubcategoryFrequency, memberList];

  @override
  String toString() {
    return 'MyTagEntity {$LOG_ID: $logId, $ID: $id, $NAME: $name, $TAG_LOG_FREQUENCY: $tagLogFrequency, '
        '$TAG_CATEGORY_FREQUENCY: $tagCategoryFrequency, $TAG_SUBCATEGORY_FREQUENCY: $tagSubcategoryFrequency, $MEMBER_LIST: $memberList}';
  }

  factory TagEntity.fromJson(Map<String, dynamic> json) => _$TagEntityFromJson(json);

  Map<String, dynamic> toJson() => _$TagEntityToJson(this);

  static TagEntity fromSnapshot(DocumentSnapshot snap) {
    return TagEntity(
      logId: snap.data()![LOG_ID],
      id: snap.id,
      name: snap.data()![NAME],
      tagLogFrequency: snap.data()![TAG_LOG_FREQUENCY],
      tagCategoryFrequency:
          (snap.data()![TAG_CATEGORY_FREQUENCY] as Map<String, dynamic>).map((key, value) => MapEntry(key, value)),
      tagSubcategoryFrequency:
      (snap.data()![TAG_SUBCATEGORY_FREQUENCY] as Map<String, dynamic>).map((key, value) => MapEntry(key, value)),
      memberList: List<String>.from(snap.data()![MEMBER_LIST] as List<dynamic>),
    );
  }
}
