import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'app_category_entity.dart';

part 'app_category.g.dart';

@immutable
//type id can never be changed
@HiveType(typeId: 1)
class AppCategory extends Equatable {
  //field ids can only be dropped, not changed
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String emojiChar;
  @HiveField(3)
  final String? parentCategoryId; //only used for subcategories

  AppCategory(
      {this.id,
      this.name,
      this.emojiChar = '\u{1F4B2}',
      this.parentCategoryId});

  @override
  List<Object> get props => [id!, name!, emojiChar];

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, emojiChar: $emojiChar, parentCategoryID: $parentCategoryId}';
  }

  AppCategoryEntity toEntity() {
    return AppCategoryEntity(
      id: id!,
      name: name!,
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
    String? id,
    String? name,
    String? emojiChar,
    String? parentCategoryId,
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
