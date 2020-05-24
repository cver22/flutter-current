import 'package:expenses/models/categories/category/category_entity.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:flutter/material.dart';

class SubcategoryEntity extends CategoryEntity {
  final String parentCategoryId;

  const SubcategoryEntity({id, name, icon, this.parentCategoryId})
      : super(icon: icon, name: name, id: id);

  @override
  List<Object> get props => [id, name, icon, parentCategoryId];

  @override
  String toString() {
    return 'SubcategoryEntity {id: $id, name: $name, icon: $icon, parentCategoryId: $parentCategoryId}';
  }

  Map<String, Object> toJson() {
    return {
      ID: id,
      NAME: name,
      ICON: icon,
      PARENT_CATEGORY_ID: parentCategoryId,
    };
  }

  static SubcategoryEntity fromJson(Map<String, Object> json) {
    return SubcategoryEntity(
      id: json[ID] as String,
      name: json[NAME] as String,
      icon: json[ICON] as Icon,
      parentCategoryId: json[PARENT_CATEGORY_ID] as String,
    );
  }
}
