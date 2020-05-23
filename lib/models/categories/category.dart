import 'package:expenses/models/categories/subcategory.dart';
import 'package:flutter/material.dart';

class Category extends Subcategory {
  final List<Subcategory> subcategories;

  Category({id, name, icon, this.subcategories})
      : super(id: id, name: name, icon: icon);

  @override
  List<Object> get props => [id, name, icon, subcategories];

  Category copyWith({
    String id,
    String name,
    Icon icon,
    List<Subcategory> subcategories,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  @override
  String toString() {
    return 'Category {id: $id, name: $name, icon: $icon, subcategories: $subcategories}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          subcategories == other.subcategories;
}
