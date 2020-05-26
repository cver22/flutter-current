import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/category/category_entity.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final IconData iconData;

  Category({@required this.id, @required this.name, this.iconData});

  @override
  List<Object> get props => [id, name, iconData];

  Category copyWith({
    String id,
    String name,
    IconData iconData,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() {
    return 'Category {id: $id, name: $name, icon: $iconData}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          name == other.id &&
          name == other.name &&
          iconData == other.iconData;

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      iconCodePoint: iconData.codePoint.toString(),
      iconFontFamily: iconData.fontFamily,
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      id: entity.id,
      name: entity.name,
      iconData: IconData(int.parse(entity.iconCodePoint),
          fontFamily: entity.iconFontFamily),
    );
  }
}
