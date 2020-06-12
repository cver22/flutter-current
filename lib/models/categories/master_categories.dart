import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/master_categories_entity.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:flutter/foundation.dart';

@immutable
class MasterCategories extends Equatable {
  final String uid; //only required for master category list
  final List<MyCategory> categories;
  final List<MySubcategory> subcategories;

  MasterCategories({this.uid, this.categories, this.subcategories});

  @override
  List<Object> get props => [uid, categories, subcategories];

  MasterCategories copyWith({
    String uid,
    List<MyCategory> categories,
    List<MySubcategory> subcategories,
  }) {
    return MasterCategories(
      uid: uid ?? this.uid,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
    );
  }

  @override
  String toString() {
    return 'MasterCategories {uid: $uid, categories: $categories, subcategories: $subcategories}';
  }


  MasterCategoriesEntity toEntity() {
    //converts firebase category maps to list for app

    return MasterCategoriesEntity(
      uid: uid,
      categories: Map<int,MyCategory>.fromIterable(categories,
          key: (e) => categories.indexOf(e), value: (e) => e),
      subcategories: Map<int,MySubcategory>.fromIterable(subcategories,
          key: (e) => subcategories.indexOf(e), value: (e) => e),
    );
  }

  static MasterCategories fromEntity(MasterCategoriesEntity entity) {
    //converts app list category lists to maps for firebase

    return MasterCategories(
      uid: entity.uid,
      categories: entity.categories.entries.map((e) => e.value).toList(),
      subcategories: entity.subcategories.entries.map((e) => e.value).toList(),
    );
  }
}
