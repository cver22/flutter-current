import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/master_categories_entity.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';


class MasterCategories extends Equatable {
  final String uid; //only required for master category list
  final Map<String, MyCategory> categories;
  final Map<String, MySubcategory> subcategories;

  MasterCategories({ this.uid, this.categories, this.subcategories});

  @override
  List<Object> get props => [uid, categories, subcategories];

  MasterCategories copyWith({
    String uid,
    Map<String, MyCategory> categories,
    Map<String, MySubcategory> subcategories,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MasterCategories &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          categories == other.categories &&
          subcategories == other.subcategories;


  MasterCategories toEntity() {
    return MasterCategories(
      uid: uid,
      categories: categories,
      subcategories: subcategories
    );
  }


  static MasterCategories fromEntity(MasterCategoriesEntity entity) {
    return MasterCategories(
      uid: entity.uid,
      categories: entity.categories,
      subcategories: entity.subcategories,
    );
  }

}
