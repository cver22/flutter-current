import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:flutter/material.dart';

class MyCategory extends Equatable {
  final String id;
  final String name;
  final IconData iconData;

  MyCategory({@required this.id, @required this.name, this.iconData});

  @override
  List<Object> get props => [id, name, iconData];

  MyCategory copyWith({
    String id,
    String name,
    IconData iconData,
  }) {
    return MyCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, icon: $iconData}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyCategory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          iconData == other.iconData;

  MyCategoryEntity toEntity() {
    return MyCategoryEntity(
      id: id,
      name: name,
      iconCodePoint: iconData.codePoint.toString(),
      iconFontFamily: iconData.fontFamily,
    );
  }

  static MyCategory fromEntity(MyCategoryEntity entity) {
    return MyCategory(
      id: entity.id,
      name: entity.name,
      iconData: IconData(int.parse(entity.iconCodePoint),
          fontFamily: entity.iconFontFamily),
    );
  }
}
