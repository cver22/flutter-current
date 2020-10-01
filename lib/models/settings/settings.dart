import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_category/my_category_entity.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory_entity.dart';
import 'package:expenses/models/settings/settings_entity.dart';
import 'package:meta/meta.dart';



@immutable
class Settings extends Equatable {

  Settings({
    this.homeCurrency,
    this.defaultCategories,
    this.defaultSubcategories,
  });

  final String homeCurrency;
  final List<MyCategory> defaultCategories;
  final List<MySubcategory> defaultSubcategories;


  Settings copyWith({
    String homeCurrency,
    List<MyCategory> defaultCategories,
    List<MySubcategory> defaultSubcategories,
    bool defaultToHomeCurrency,
  }) {
    return Settings(
      homeCurrency: homeCurrency ?? this.homeCurrency,
      defaultCategories: defaultCategories ?? this.defaultCategories,
      defaultSubcategories: defaultSubcategories ?? this.defaultSubcategories,
    );
  }

  @override
  List<Object> get props =>
      [homeCurrency, defaultCategories, defaultSubcategories];

  @override
  bool get stringify => true;

  SettingsEntity toEntity() {
    //converts from model to entities
    List<MyCategoryEntity> defaultCategoryEntities = [];
    defaultCategories.every((e) {
      defaultCategoryEntities.add(e.toEntity());
      return true;
    });
    List<MySubcategoryEntity> defaultSubcategoryEntities = [];
    defaultSubcategories.every((e) {
      defaultSubcategoryEntities.add(e.toEntity());
      return true;
    });

    return SettingsEntity(
      homeCurrency: homeCurrency,
      defaultCategoryEntities: defaultCategoryEntities,
      defaultSubcategoryEntities: defaultSubcategoryEntities,
    );
  }

  static Settings fromEntity(SettingsEntity entity) {
    //converts entity back to model
    List<MyCategory> returnedDefaultCategories = [];
    entity.defaultCategoryEntities.every((e) {
      returnedDefaultCategories.add(MyCategory.fromEntity(e));
      return true;
    });

    List<MySubcategory> returnedDefaultSubcategories = [];
    entity.defaultSubcategoryEntities.every((e) {
      returnedDefaultSubcategories.add(MySubcategory.fromEntity(e));
      return true;
    });

    return Settings(
      homeCurrency: entity.homeCurrency,
      defaultCategories: returnedDefaultCategories,
      defaultSubcategories: returnedDefaultSubcategories,
    );
  }
}
