import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/category/category_entity.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final Icon icon;

  Category({@required this.id, @required this.name, this.icon});

  @override
  List<Object> get props => [id, name, icon];

  Category copyWith({
    String id,
    String name,
    Icon icon,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'Category {id: $id, name: $name, icon: $icon}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          name == other.id &&
          name == other.name &&
          icon == other.icon;

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      icon: icon,
    );
  }

  static Category fromEntity(CategoryEntity entity) {
    return Category(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
    );
  }
}
