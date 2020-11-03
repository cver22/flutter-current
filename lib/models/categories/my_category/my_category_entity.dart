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
  final bool isDefault;
  final String emojiChar;

  const MyCategoryEntity(
      {this.id, this.name, this.iconCodePoint, this.iconFontFamily, this.isDefault = false, this.emojiChar});

  @override
  List<Object> get props => [id, name, iconCodePoint, iconFontFamily, isDefault, emojiChar];

  @override
  String toString() {
    return 'MyCategoryEntity {id: $id, name: $name, iconCodePoint: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily, isDefault: $isDefault, emojiChar $emojiChar}';
  }

  factory MyCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MyCategoryEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MyCategoryEntityToJson(this);

}
