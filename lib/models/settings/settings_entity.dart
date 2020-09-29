
import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

@immutable
//@JsonSerializable(explicitToJson: true)
class SettingsEntity implements Equatable {

  const SettingsEntity({
    this.homeCurrency,
    this.defaultCategories,
    this.defaultSubcategories,
  });

  final String homeCurrency;
  final List<MyCategory> defaultCategories;
  final List<MySubcategory> defaultSubcategories;

  @override
  List<Object> get props =>
      [homeCurrency, defaultCategories, defaultSubcategories];

  @override
  bool get stringify => true;

  //TODO implement local JSON parsing and data storage


}