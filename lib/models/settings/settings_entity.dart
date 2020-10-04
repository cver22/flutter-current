import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory_entity.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'settings_entity.g.dart';

@immutable
@JsonSerializable()
class SettingsEntity implements Equatable {
  const SettingsEntity({
    this.homeCurrency,
    this.defaultCategoryEntities,
    this.defaultSubcategoryEntities,
    this.defaultLogId,
  });

  final String homeCurrency;
  final List<MyCategoryEntity> defaultCategoryEntities;
  final List<MySubcategoryEntity> defaultSubcategoryEntities;
  final String defaultLogId;

  @override
  List<Object> get props =>
      [homeCurrency, defaultCategoryEntities, defaultSubcategoryEntities, defaultLogId];

  @override
  bool get stringify => true;

  factory SettingsEntity.fromJson(Map<String, dynamic> json) =>
      _$SettingsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsEntityToJson(this);
}
