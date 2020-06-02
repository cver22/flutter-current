// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyCategoryEntity _$MyCategoryEntityFromJson(Map<String, dynamic> json) {
  return MyCategoryEntity(
    name: json['name'] as String,
    iconCodePoint: json['iconCodePoint'] as String,
    iconFontFamily: json['iconFontFamily'] as String,
  );
}

Map<String, dynamic> _$MyCategoryEntityToJson(MyCategoryEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'iconCodePoint': instance.iconCodePoint,
      'iconFontFamily': instance.iconFontFamily,
    };
