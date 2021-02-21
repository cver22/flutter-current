import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/categories/categories_model/app_category/app_category_entity.dart';
import 'package:expenses/settings/settings_model/settings_entity.dart';
import 'package:meta/meta.dart';

@immutable
class Settings extends Equatable {
  Settings(
      {this.homeCurrency,
      this.defaultCategories,
      this.defaultSubcategories,
      this.defaultLogId,
      this.autoInsertDecimalPoint});

  final String homeCurrency;
  final List<AppCategory> defaultCategories;
  final List<AppCategory> defaultSubcategories;
  final String defaultLogId;
  final bool autoInsertDecimalPoint;

  Settings copyWith(
      {String homeCurrency,
      List<AppCategory> defaultCategories,
      List<AppCategory> defaultSubcategories,
      String defaultLogId,
      String autoInsertDecimalPoint}) {
    return Settings(
      homeCurrency: homeCurrency ?? this.homeCurrency,
      defaultCategories: defaultCategories ?? this.defaultCategories,
      defaultSubcategories: defaultSubcategories ?? this.defaultSubcategories,
      defaultLogId: defaultLogId ?? this.defaultLogId,
      autoInsertDecimalPoint: autoInsertDecimalPoint ?? this.autoInsertDecimalPoint,
    );
  }

  @override
  List<Object> get props =>
      [homeCurrency, defaultCategories, defaultSubcategories, defaultLogId, autoInsertDecimalPoint];

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
      homeCurrency: entity.homeCurrency,
      defaultCategories: returnedDefaultCategories,
      defaultSubcategories: returnedDefaultSubcategories,
      defaultLogId: entity.defaultLogId,
      autoInsertDecimalPoint: entity.autoInsertDecimalPoint,
    );
  }
}
