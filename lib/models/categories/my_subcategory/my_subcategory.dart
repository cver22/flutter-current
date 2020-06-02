import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory_entity.dart';
import 'package:flutter/material.dart';

class MySubcategory extends MyCategory {
  final String parentCategoryId;

  MySubcategory({id, name, iconData, @required this.parentCategoryId})
      : super(id: id, name: name, iconData: iconData);

  @override
  List<Object> get props => [parentCategoryId, id, name, iconData];

  @override
  MySubcategory copyWith({
    String parentCategoryId,
    String id,
    String name,
    IconData iconData,
  }) {
    return MySubcategory(
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() {
    return 'MySubcategory {parentCategoryId: $parentCategoryId, id: $id, name: $name, iconData: $iconData}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MySubcategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          parentCategoryId == other.parentCategoryId &&
          name == other.name &&
          iconData == other.iconData;

  @override
  MySubcategoryEntity toEntity() {
    return MySubcategoryEntity(
      parentCategoryId: parentCategoryId,
      id: id,
      name: name,
      iconCodePoint: iconData?.codePoint.toString(),
      iconFontFamily: iconData?.fontFamily,
    );
  }

  @override
  static MySubcategory fromEntity(MySubcategoryEntity entity) {
    return MySubcategory(
      parentCategoryId: entity.parentCategoryId,
      id: entity.id,
      name: entity.name,
      iconData: entity?.iconCodePoint != null && entity?.iconFontFamily !=null ?IconData(int.parse(entity.iconCodePoint),
          fontFamily: entity.iconFontFamily) : null,
    );
  }
}
