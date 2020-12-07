import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category_entity.dart';
import 'package:flutter/material.dart';

@immutable
class MyCategory extends Equatable {
  final String id;
  final String name;
  final String emojiChar;
  final Map<String,int> tagIdFrequency;

  MyCategory({this.id, @required this.name, this.emojiChar, this.tagIdFrequency = const {}});

  @override
  List<Object> get props => [id, name, emojiChar, tagIdFrequency];

  MyCategory copyWith({String id, String name, String emojiChar, Map<String,int> tagIdFrequency}) {
    return MyCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      emojiChar: emojiChar ?? this.emojiChar,
      tagIdFrequency: tagIdFrequency ?? this.tagIdFrequency,
    );
  }

  @override
  String toString() {
    return 'MyCategory {id: $id, name: $name, emojiChar: $emojiChar, tagIdFrequency: $tagIdFrequency}';
  }

  MyCategoryEntity toEntity() {
    return MyCategoryEntity(
      id: id,
      name: name,
      emojiChar: emojiChar,
      tagIdFrequency: tagIdFrequency,
    );
  }

  static MyCategory fromEntity(MyCategoryEntity entity) {
    return MyCategory(
      id: entity.id,
      name: entity.name,
      emojiChar: entity.emojiChar,
      tagIdFrequency: entity.tagIdFrequency,
      //TODO start here
    );
  }
}
