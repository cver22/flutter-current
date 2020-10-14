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
  }) : super(
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            name: name,
            id: id,
  isDefault: isDefault);

  @override
  List<Object> get props =>
      [id, name, iconCodePoint, iconFontFamily, parentCategoryId, isDefault];

  @override
  String toString() {
    return 'MySubcategoryEntity {$ID: $id, $NAME: $name, $ICON_CODE_POINT: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily, $PARENT_CATEGORY_ID: $parentCategoryId, isDefault: $isDefault}';
  }

  @override
  factory MySubcategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MySubcategoryEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MySubcategoryEntityToJson(this);
}
