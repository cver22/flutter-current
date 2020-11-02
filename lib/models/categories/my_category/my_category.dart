import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:flutter/material.dart';

@immutable
class MyCategory extends Equatable {
  final String id;
  final String name;
  final IconData iconData; //TODO - change to use emoji
  final bool isDefault;

  MyCategory({this.id, @required this.name, this.iconData, this.isDefault = false});

  @override
  List<Object> get props => [id, name, iconData, isDefault];

  MyCategory copyWith({
    String id,
    String name,
    IconData iconData,
    bool isDefault,
  }) {
    return MyCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconData: iconData ?? this.iconData,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, icon: $iconData, isDefault: $isDefault}';
  }

  MyCategoryEntity toEntity() {
    return MyCategoryEntity(
      id: id,
      name: name,
      iconCodePoint: iconData?.codePoint.toString(),
      iconFontFamily: iconData?.fontFamily,
      isDefault: isDefault,
    );
  }

  static MyCategory fromEntity(MyCategoryEntity entity) {
    return MyCategory(
      id: entity.id,
      name: entity.name,
      iconData: entity?.iconCodePoint != null && entity?.iconFontFamily !=null ? IconData(int.parse(entity.iconCodePoint),
          fontFamily: entity.iconFontFamily) : null,
      isDefault: entity.isDefault,
    );
  }
}
