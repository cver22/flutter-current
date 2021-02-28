import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'app_category_entity.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
class AppCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String emojiChar;
  final String parentCategoryId;

  const AppCategoryEntity({this.id, this.name, this.emojiChar, this.parentCategoryId});

  @override
  List<Object> get props => [id, name, emojiChar, parentCategoryId];

  @override
  String toString() {
    return 'MyCategoryEntity {id: $id, name: $name, emojiChar $emojiChar parentCategoryId: $parentCategoryId}';
  }

  factory AppCategoryEntity.fromJson(Map<String, dynamic> json) => _$MyCategoryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MyCategoryEntityToJson(this);
}