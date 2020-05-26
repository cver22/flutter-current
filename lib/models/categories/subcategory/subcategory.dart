import 'package:expenses/models/categories/category/category.dart';
import 'package:expenses/models/categories/subcategory/subcategory_entity.dart';
import 'package:flutter/material.dart';

class Subcategory extends Category {
  final String parentCategoryId;

  Subcategory({id, name, iconData, @required this.parentCategoryId})
      : super(id: id, name: name, iconData: iconData);

  @override
  List<Object> get props => [parentCategoryId, id, name, iconData];

  @override
  Subcategory copyWith({
    String parentCategoryId,
    String id,
    String name,
    IconData iconData,
  }) {
    return Subcategory(
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() {
    return 'Subcategory {parentCategoryId: $parentCategoryId, id: $id, name: $name, iconData: $iconData}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subcategory &&
          runtimeType == other.runtimeType &&
          parentCategoryId == other.parentCategoryId &&
          name == other.id &&
          name == other.name &&
          iconData == other.iconData;

  @override
  SubcategoryEntity toEntity() {
    return SubcategoryEntity(
      parentCategoryId: parentCategoryId,
      id: id,
      name: name,
      iconCodePoint: iconData.codePoint.toString(),
      iconFontFamily: iconData.fontFamily,
    );
  }

  @override
  static Subcategory fromEntity(SubcategoryEntity entity) {
    return Subcategory(
      parentCategoryId: entity.parentCategoryId,
      id: entity.id,
      name: entity.name,
      iconData: IconData(int.parse(entity.iconCodePoint),
          fontFamily: entity.iconFontFamily),
    );
  }
}
