import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory_entity.dart';
import 'package:flutter/material.dart';

@immutable
class MySubcategory extends MyCategory {
  final String parentCategoryId;

  MySubcategory({id, name, isDefault, emojiChar, @required this.parentCategoryId})
      : super(id: id, name: name, isDefault: isDefault, emojiChar: emojiChar);

  @override
  List<Object> get props => [parentCategoryId, id, name, isDefault, emojiChar];

  @override
  MySubcategory copyWith({
    String parentCategoryId,
    String id,
    String name,
    bool isDefault,
    String emojiChar,
  }) {
    return MySubcategory(
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      emojiChar: emojiChar ?? this.emojiChar,
    );
  }

  @override
  String toString() {
    return 'MySubcategory {parentCategoryId: $parentCategoryId, id: $id, name: $name, isDefault $isDefault, emojiChar: $emojiChar}';
  }


  @override
  MySubcategoryEntity toEntity() {
    return MySubcategoryEntity(
      parentCategoryId: parentCategoryId,
      id: id,
      name: name,
      isDefault: isDefault,
      emojiChar: emojiChar,
    );
  }

  @override
  static MySubcategory fromEntity(MySubcategoryEntity entity) {
    return MySubcategory(
      parentCategoryId: entity.parentCategoryId,
      id: entity.id,
      name: entity.name,
      isDefault: entity.isDefault,
      emojiChar: entity.emojiChar,
    );
  }
}
