import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
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
    return SettingsEntity(
      homeCurrency: homeCurrency,
      defaultCategories: defaultCategories,
      defaultSubcategories: defaultSubcategories,
    );
  }

  static Settings fromEntity(SettingsEntity entity) {
    return Settings(
      homeCurrency: entity.homeCurrency,
      defaultCategories: entity.defaultCategories,
      defaultSubcategories: entity.defaultSubcategories,
    );
  }
}
