import 'package:expenses/models/categories/category/category_entity.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subcategory_entity.g.dart';

@JsonSerializable()
class SubcategoryEntity extends CategoryEntity {
  final String parentCategoryId;

  const SubcategoryEntity({
    id,
    name,
    iconCodePoint,
    iconFontFamily,
    this.parentCategoryId,
  }) : super(
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            name: name,
            id: id);

  @override
  List<Object> get props =>
      [id, name, iconCodePoint, iconFontFamily, parentCategoryId];

  @override
  String toString() {
    return 'SubcategoryEntity {$ID: $id, $NAME: $name, $ICON_CODE_POINT: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily, $PARENT_CATEGORY_ID: $parentCategoryId}';
  }

  @override
  factory SubcategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$SubcategoryEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SubcategoryEntityToJson(this);
}
