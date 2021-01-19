import 'package:equatable/equatable.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_category/my_category_entity.dart';
import 'package:expenses/settings/settings_model/settings_entity.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

@immutable
class Settings extends Equatable {
  Settings(
      {this.homeCurrency,
      this.defaultCategories,
      this.defaultSubcategories,
      this.defaultLogId,
      this.autoInsertDecimalPoint});

  final String homeCurrency;
  final List<MyCategory> defaultCategories;
  final List<MyCategory> defaultSubcategories;
  final String defaultLogId;
  final bool autoInsertDecimalPoint;

  Settings copyWith(
      {String homeCurrency,
      List<MyCategory> defaultCategories,
      List<MyCategory> defaultSubcategories,
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

  Settings editSettingCategories({Settings settings, MyCategory category}) {
    List<MyCategory> categories = settings.defaultCategories;

    if (category.id != null) {
      categories[categories.indexWhere((e) => e.id == category.id)] = category;
    } else {
      categories.add(category.copyWith(id: Uuid().v4()));
    }

    return settings.copyWith(defaultCategories: categories);
  }

  Settings editSettingSubcategories({Settings settings, MyCategory subcategory}) {
    List<MyCategory> subcategories = settings.defaultSubcategories;

    if (subcategory.id != null) {
      subcategories[subcategories.indexWhere((e) => e.id == subcategory.id)] = subcategory;
    } else {
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    }

    return settings.copyWith(defaultSubcategories: subcategories);
  }

  @override
  List<Object> get props =>
      [homeCurrency, defaultCategories, defaultSubcategories, defaultLogId, autoInsertDecimalPoint];

  @override
  bool get stringify => true;

  SettingsEntity toEntity() {
    //converts from model to entities
    List<MyCategoryEntity> defaultCategoryEntities = [];
    defaultCategories.every((e) {
      defaultCategoryEntities.add(e.toEntity());
      return true;
    });
    List<MyCategoryEntity> defaultSubcategoryEntities = [];
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
    List<MyCategory> returnedDefaultCategories = [];
    entity.defaultCategoryEntities.every((e) {
      returnedDefaultCategories.add(MyCategory.fromEntity(e));
      return true;
    });

    List<MyCategory> returnedDefaultSubcategories = [];
    entity.defaultSubcategoryEntities.every((e) {
      returnedDefaultSubcategories.add(MyCategory.fromEntity(e));
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
