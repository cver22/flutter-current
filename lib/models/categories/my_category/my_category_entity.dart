import 'package:equatable/equatable.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_category_entity.g.dart';

@immutable
@JsonSerializable()
class MyCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String iconCodePoint;
  final String iconFontFamily;

  const MyCategoryEntity(
      {this.id, this.name, this.iconCodePoint, this.iconFontFamily});

  @override
  List<Object> get props => [id, name, iconCodePoint, iconFontFamily];

  @override
  String toString() {
    return 'MyCategoryEntity {id: $id, name: $name, iconCodePoint: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily }';
  }

  factory MyCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MyCategoryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MyCategoryEntityToJson(this);
}
