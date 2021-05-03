import 'package:equatable/equatable.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

import 'app_category_entity.dart';

@immutable
class AppCategory extends Equatable {
  final String id;
  final String name;
  final String emojiChar;
  final String parentCategoryId; //only used for subcategories

  AppCategory(
      {this.id = '',
      this.name = '',
      this.emojiChar = '\u{1F4B2}',
      this.parentCategoryId = NO_PARENT});

  @override
  List<Object> get props => [id, name, emojiChar, parentCategoryId];

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, emojiChar: $emojiChar, parentCategoryID: $parentCategoryId}';
  }

  AppCategoryEntity toEntity() {
    return AppCategoryEntity(
      id: id,
      name: name,
      emojiChar: emojiChar,
      parentCategoryId: parentCategoryId,
    );
  }

  static AppCategory fromEntity(AppCategoryEntity entity) {
    return AppCategory(
      id: entity.id,
      name: entity.name,
      emojiChar: entity.emojiChar,
      parentCategoryId: entity.parentCategoryId,
    );
  }

  AppCategory copyWith({
    String id,
    String name,
    String emojiChar,
    String parentCategoryId,
  }) {
    if ((id == null || identical(id, this.id)) &&
        (name == null || identical(name, this.name)) &&
        (emojiChar == null || identical(emojiChar, this.emojiChar)) &&
        (parentCategoryId == null ||
            identical(parentCategoryId, this.parentCategoryId))) {
      return this;
    }

    return new AppCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      emojiChar: emojiChar ?? this.emojiChar,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
    );
  }
}
