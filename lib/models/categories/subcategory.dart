import 'package:expenses/models/categories/category.dart';
import 'package:flutter/material.dart';

class Subcategory extends Category {
  final String parentCategoryId;

  Subcategory({id, name, icon, this.parentCategoryId})
      : super(id: id, name: name, icon: icon);

  @override
  List<Object> get props => [parentCategoryId, id, name, icon];

  Subcategory copyWith({
    String parentCategoryId,
    String id,
    String name,
    Icon icon,
  }) {
    return Subcategory(
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'Subcategory {parentCategoryId: $parentCategoryId, id: $id, name: $name, icon: $icon}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subcategory &&
          runtimeType == other.runtimeType &&
          parentCategoryId == other.parentCategoryId &&
          name == other.id &&
          name == other.name &&
          icon == other.icon;
}
