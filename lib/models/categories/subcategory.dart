import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Subcategory extends Equatable {
  final String id;
  final String name;
  final Icon icon;

  Subcategory({this.id, this.name, this.icon});

  @override
  List<Object> get props => [id, name, icon];

  Subcategory copyWith({
    String id,
    String name,
    Icon icon,
  }) {
    return Subcategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'Subcategory {id: $id, name: $name, icon: $icon}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subcategory &&
          runtimeType == other.runtimeType &&
          name == other.id &&
          name == other.name &&
          icon == other.icon;
}
