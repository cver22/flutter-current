import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category_entity.dart';
import 'package:flutter/material.dart';

@immutable
class MyCategory extends Equatable {
  final String id;
  final String name;
  final bool isDefault;
  final String emojiChar;

  MyCategory( {this.id, @required this.name, this.isDefault = false, this.emojiChar});

  @override
  List<Object> get props => [id, name, isDefault, emojiChar];

  MyCategory copyWith({
    String id,
    String name,

    bool isDefault,
    String emojiChar
  }) {
    return MyCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      emojiChar: emojiChar ?? this.emojiChar,
    );
  }

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, isDefault: $isDefault, emojiChar: $emojiChar}';
  }

  MyCategoryEntity toEntity() {
    return MyCategoryEntity(
      id: id,
      name: name,
      isDefault: isDefault,
      emojiChar: emojiChar,
    );
  }

  static MyCategory fromEntity(MyCategoryEntity entity) {
    return MyCategory(
      id: entity.id,
      name: entity.name,
      isDefault: entity.isDefault,
      emojiChar: entity.emojiChar,
    );
  }
}
