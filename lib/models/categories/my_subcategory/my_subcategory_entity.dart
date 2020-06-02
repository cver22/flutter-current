import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:json_annotation/json_annotation.dart';

part 'my_subcategory_entity.g.dart';

@JsonSerializable()
class MySubcategoryEntity extends MyCategoryEntity {
  final String parentCategoryId;

  const MySubcategoryEntity({

    name,
    iconCodePoint,
    iconFontFamily,
    this.parentCategoryId,
  }) : super(
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            name: name,
           );

  @override
  List<Object> get props =>
      [name, iconCodePoint, iconFontFamily, parentCategoryId];

  @override
  String toString() {
    return 'MySubcategoryEntity {$NAME: $name, $ICON_CODE_POINT: $iconCodePoint, $ICON_FONT_FAMILY: $iconFontFamily, $PARENT_CATEGORY_ID: $parentCategoryId}';
  }

  @override
  factory MySubcategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MySubcategoryEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MySubcategoryEntityToJson(this);
}
