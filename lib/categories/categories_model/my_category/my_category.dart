import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category_entity.dart';
import 'package:flutter/material.dart';

@immutable
class MyCategory extends Equatable {
  final String id;
  final String name;
  final String emojiChar;
  final String parentCategoryId; //only used for subcategories


  MyCategory( {this.id, this.name = '', this.emojiChar = '\u{1F4B2}',this.parentCategoryId});

  @override
  List<Object> get props => [id, name, emojiChar, parentCategoryId];

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, emojiChar: $emojiChar, parentCategoryID: $parentCategoryId}';
  }

  MyCategoryEntity toEntity() {
    return MyCategoryEntity(
      id: id,
      name: name,
      emojiChar: emojiChar,
      parentCategoryId: parentCategoryId,
    );
  }

  static MyCategory fromEntity(MyCategoryEntity entity) {
    return MyCategory(
      id: entity.id,
      name: entity.name,
      emojiChar: entity.emojiChar,
      parentCategoryId: entity.parentCategoryId,
    );
  }

  MyCategory copyWith({
    String id,
    String name,
    String emojiChar,
    String parentCategoryId,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (emojiChar == null || identical(emojiChar, this.emojiChar)) &&
        (parentCategoryId == null || identical(parentCategoryId, this.parentCategoryId))) {
      return this;
    }

    return new MyCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      emojiChar: emojiChar ?? this.emojiChar,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
    );
  }
}
