import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import '../../categories/categories_model/app_category/app_category_entity.dart';
import 'settings_entity.dart';

part 'settings.g.dart';

@immutable
//type id can never be changed
@HiveType(typeId: 0)
class Settings extends Equatable {
  @HiveField(0)
  final String homeCurrency;
  @HiveField(1)
  final List<AppCategory> defaultCategories;
  @HiveField(2)
  final List<AppCategory> defaultSubcategories;
  @HiveField(3)
  final String? defaultLogId;
  @HiveField(4)
  final bool? autoInsertDecimalPoint;
  @HiveField(5)
  final List<String>? logOrder;

  Settings(
      {required this.homeCurrency,
      required this.defaultCategories,
      required this.defaultSubcategories,
      this.defaultLogId,
      this.autoInsertDecimalPoint = false,
      required this.logOrder});

  @override
  List<Object?> get props => [
        homeCurrency,
        defaultCategories,
        defaultSubcategories,
        defaultLogId,
        autoInsertDecimalPoint,
        logOrder
      ];

  @override
  bool get stringify => true;

  SettingsEntity toEntity() {
    //converts from model to entities
    List<AppCategoryEntity> defaultCategoryEntities = [];
    defaultCategories.every((e) {
      defaultCategoryEntities.add(e.toEntity());
      return true;
    });
    List<AppCategoryEntity> defaultSubcategoryEntities = [];
    defaultSubcategories.every((e) {
      defaultSubcategoryEntities.add(e.toEntity());
      return true;
    });

    return SettingsEntity(
      homeCurrency: homeCurrency,
      defaultCategoryEntities: defaultCategoryEntities,
      defaultSubcategoryEntities: defaultSubcategoryEntities,
      defaultLogId: defaultLogId,
      autoInsertDecimalPoint: autoInsertDecimalPoint,
      logOrder: logOrder,
    );
  }

  static Settings fromEntity(SettingsEntity entity) {
    //converts entity back to model
    List<AppCategory> returnedDefaultCategories = [];
    entity.defaultCategoryEntities.every((e) {
      returnedDefaultCategories.add(AppCategory.fromEntity(e));
      return true;
    });

    List<AppCategory> returnedDefaultSubcategories = [];
    entity.defaultSubcategoryEntities.every((e) {
      returnedDefaultSubcategories.add(AppCategory.fromEntity(e));
      return true;
    });

    return Settings(
      homeCurrency: entity.homeCurrency!,
      defaultCategories: returnedDefaultCategories,
      defaultSubcategories: returnedDefaultSubcategories,
      defaultLogId: entity.defaultLogId,
      autoInsertDecimalPoint: entity.autoInsertDecimalPoint,
      logOrder: entity.logOrder,
    );
  }

  Settings copyWith({
    String? homeCurrency,
    List<AppCategory>? defaultCategories,
    List<AppCategory>? defaultSubcategories,
    String? defaultLogId,
    bool? autoInsertDecimalPoint,
    List<String>? logOrder,
  }) {
    if ((homeCurrency == null || identical(homeCurrency, this.homeCurrency)) &&
        (defaultCategories == null ||
            identical(defaultCategories, this.defaultCategories)) &&
        (defaultSubcategories == null ||
            identical(defaultSubcategories, this.defaultSubcategories)) &&
        (defaultLogId == null || identical(defaultLogId, this.defaultLogId)) &&
        (autoInsertDecimalPoint == null ||
            identical(autoInsertDecimalPoint, this.autoInsertDecimalPoint)) &&
        (logOrder == null || identical(logOrder, this.logOrder))) {
      return this;
    }

    return new Settings(
      homeCurrency: homeCurrency ?? this.homeCurrency,
      defaultCategories: defaultCategories ?? this.defaultCategories,
      defaultSubcategories: defaultSubcategories ?? this.defaultSubcategories,
      defaultLogId: defaultLogId ?? this.defaultLogId,
      autoInsertDecimalPoint:
          autoInsertDecimalPoint ?? this.autoInsertDecimalPoint,
      logOrder: logOrder ?? this.logOrder,
    );
  }
}
