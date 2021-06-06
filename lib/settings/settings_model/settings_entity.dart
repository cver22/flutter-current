import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../../categories/categories_model/app_category/app_category_entity.dart';

part 'settings_entity.g.dart';

@immutable
@JsonSerializable()
class SettingsEntity implements Equatable {
  const SettingsEntity({
    required this.homeCurrency,
    this.defaultCategoryEntities = const [],
    this.defaultSubcategoryEntities = const [],
    this.defaultLogId,
    this.autoInsertDecimalPoint = false,
    this.logOrder = const <String>[],
  });

  final String homeCurrency;
  final List<AppCategoryEntity> defaultCategoryEntities;
  final List<AppCategoryEntity> defaultSubcategoryEntities;
  final String? defaultLogId;
  final bool autoInsertDecimalPoint;
  final List<String>? logOrder;

  @override
  List<Object?> get props => [
        homeCurrency,
        defaultCategoryEntities,
        defaultSubcategoryEntities,
        defaultLogId,
        autoInsertDecimalPoint,
        logOrder
      ];

  @override
  bool get stringify => true;

  factory SettingsEntity.fromJson(Map<String, dynamic> json) =>
      _$SettingsEntityFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsEntityToJson(this);
}
