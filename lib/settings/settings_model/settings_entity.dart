import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../../categories/categories_model/app_category/app_category_entity.dart';

//part 'settings_entity.g.dart';

@immutable
@JsonSerializable()
class SettingsEntity implements Equatable {
  const SettingsEntity({
    this.homeCurrency,
    this.defaultCategoryEntities,
    this.defaultSubcategoryEntities,
    this.defaultLogId,
    this.autoInsertDecimalPoint,
    this.logOrder,
  });

  final String homeCurrency;
  final List<AppCategoryEntity> defaultCategoryEntities;
  final List<AppCategoryEntity> defaultSubcategoryEntities;
  final String defaultLogId;
  final bool autoInsertDecimalPoint;
  final List<String> logOrder;

  @override
  List<Object> get props => [
        homeCurrency,
        defaultCategoryEntities,
        defaultSubcategoryEntities,
        defaultLogId,
        autoInsertDecimalPoint,
        logOrder
      ];

  @override
  bool get stringify => true;

 /* factory SettingsEntity.fromJson(Map<String, dynamic> json) =>
      _$SettingsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsEntityToJson(this);*/
}
