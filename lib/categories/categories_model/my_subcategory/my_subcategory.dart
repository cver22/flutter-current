import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_subcategory/my_subcategory_entity.dart';
import 'package:flutter/material.dart';

@immutable
class MySubcategory extends MyCategory {
  final String parentCategoryId;

  MySubcategory({id, name, emojiChar, @required this.parentCategoryId})
      : super(id: id, name: name, emojiChar: emojiChar);

  @override
  List<Object> get props => [parentCategoryId, id, name, emojiChar];

  @override
  MySubcategory copyWith({
    String parentCategoryId,
    String id,
    String name,
    String emojiChar,
  }) {
    return MySubcategory(
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      id: id ?? this.id,
      name: name ?? this.name,
      emojiChar: emojiChar ?? this.emojiChar,
    );
  }

  @override
  String toString() {
    return 'MySubcategory {parentCategoryId: $parentCategoryId, id: $id, name: $name, emojiChar: $emojiChar}';
  }


  @override
  MySubcategoryEntity toEntity() {
    return MySubcategoryEntity(
      parentCategoryId: parentCategoryId,
      id: id,
      name: name,
      emojiChar: emojiChar,
    );
  }

  @override
  static MySubcategory fromEntity(MySubcategoryEntity entity) {
    return MySubcategory(
      parentCategoryId: entity.parentCategoryId,
      id: entity.id,
      name: entity.name,
      emojiChar: entity.emojiChar,
    );
  }
}
