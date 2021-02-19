import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/app_category/app_category_entity.dart';
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
    this.autoInsertDecimalPoint,
  });

  final String homeCurrency;
  final List<AppCategoryEntity> defaultCategoryEntities;
  final List<AppCategoryEntity> defaultSubcategoryEntities;
  final String defaultLogId;
  final bool autoInsertDecimalPoint;

  @override
  List<Object> get props =>
      [homeCurrency, defaultCategoryEntities, defaultSubcategoryEntities, defaultLogId, autoInsertDecimalPoint];

  @override
  bool get stringify => true;

  factory SettingsEntity.fromJson(Map<String, dynamic> json) =>
      _$SettingsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsEntityToJson(this);

}
