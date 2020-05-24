import 'package:equatable/equatable.dart';
import 'package:expenses/res/db_consts.dart';
import 'package:flutter/material.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final Icon icon;

  const CategoryEntity({this.id, this.name, this.icon});

  @override
  List<Object> get props => [id, name, icon];

  @override
  String toString() {
    return 'CategoryEntity {id: $id, name: $name, icon: $icon}';
  }

  Map<String, Object> toJson() {
    return {
      ID: id,
      NAME: name,
      ICON: icon,
    };
  }

  static CategoryEntity fromJson(Map<String, Object> json) {
    return CategoryEntity(
        id: json[ID] as String,
        name: json[NAME] as String,
        icon: json[ICON] as Icon);
  }
}
