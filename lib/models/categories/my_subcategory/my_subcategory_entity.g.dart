// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_subcategory_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MySubcategoryEntity _$MySubcategoryEntityFromJson(Map<String, dynamic> json) {
  return MySubcategoryEntity(
    id: json['id'],
    name: json['name'],
    isDefault: json['isDefault'],
    parentCategoryId: json['parentCategoryId'] as String,
    emojiChar: json['emojiChar'],
  );
}

Map<String, dynamic> _$MySubcategoryEntityToJson(
        MySubcategoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'isDefault': instance.isDefault,
      'emojiChar': instance.emojiChar,
      'parentCategoryId': instance.parentCategoryId,
    };
