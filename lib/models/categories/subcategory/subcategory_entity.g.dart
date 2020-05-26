// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subcategory_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubcategoryEntity _$SubcategoryEntityFromJson(Map<String, dynamic> json) {
  return SubcategoryEntity(
    id: json['id'],
    name: json['name'],
    iconCodePoint: json['iconCodePoint'],
    iconFontFamily: json['iconFontFamily'],
    parentCategoryId: json['parentCategoryId'] as String,
  );
}

Map<String, dynamic> _$SubcategoryEntityToJson(SubcategoryEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconCodePoint': instance.iconCodePoint,
      'iconFontFamily': instance.iconFontFamily,
      'parentCategoryId': instance.parentCategoryId,
    };
