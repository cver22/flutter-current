import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_subcategory_entity.g.dart';

@immutable
@JsonSerializable()
class MySubcategoryEntity extends MyCategoryEntity {
  final String parentCategoryId;

  const MySubcategoryEntity({
    id,
    name,
    iconCodePoint,
    iconFontFamily,
    isDefault,
    this.parentCategoryId,
    emojiChar,
  }) : super(
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            name: name,
            id: id,
            isDefault: isDefault,
            emojiChar: emojiChar);

  @override
  List<Object> get props => [id, name, iconCodePoint, iconFontFamily, parentCategoryId, isDefault, emojiChar];

  @override
  String toString() {
    return 'MySubcategoryEntity {$ID: $id, $NAME: $name, $ICON_CODE_POINT: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily, $PARENT_CATEGORY_ID: $parentCategoryId, isDefault: $isDefault, emojiChar: $emojiChar}';
  }

  @override
  factory MySubcategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MySubcategoryEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MySubcategoryEntityToJson(this);

}
