import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:flutter/material.dart';

class MyCategory extends Equatable {
  final String name;
  final IconData iconData;

  MyCategory({@required this.name, this.iconData});

  @override
  List<Object> get props => [name, iconData];

  MyCategory copyWith({
    String name,
    IconData iconData,
  }) {
    return MyCategory(
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
    );
  }

  @override
  String toString() {
    return 'MyCategory {name: $name, icon: $iconData}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MyCategory &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          iconData == other.iconData;

  MyCategoryEntity toEntity() {
    return MyCategoryEntity(
      name: name,
      iconCodePoint: iconData?.codePoint.toString(),
      iconFontFamily: iconData?.fontFamily,
    );
  }

  static MyCategory fromEntity(MyCategoryEntity entity) {
    return MyCategory(
      name: entity.name,
      iconData: entity?.iconCodePoint != null && entity?.iconFontFamily !=null ? IconData(int.parse(entity.iconCodePoint),
          fontFamily: entity.iconFontFamily) : null,
    );
  }
}
