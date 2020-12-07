
import 'package:expenses/categories/categories_model/my_category/my_category_entity.dart';
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
    this.parentCategoryId,
    emojiChar,
  }) : super(
            name: name,
            id: id,
            emojiChar: emojiChar);

  @override
  List<Object> get props => [id, name, parentCategoryId, emojiChar];

  @override
  String toString() {
    return 'MySubcategoryEntity {$ID: $id, $NAME: $name, $PARENT_CATEGORY_ID: $parentCategoryId, emojiChar: $emojiChar}';
  }

  @override
  factory MySubcategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MySubcategoryEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MySubcategoryEntityToJson(this);

}
