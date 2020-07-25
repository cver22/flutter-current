import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/utils/maybe.dart';

class CategoriesState extends Equatable {
  final Maybe<List<MyCategory>> categories;
  final Maybe<List<MySubcategory>> subcategories;

  CategoriesState({this.categories, this.subcategories});

  factory CategoriesState.initial() {
    return CategoriesState(
      categories: Maybe.none(),
      subcategories: Maybe.none(),
    );
  }

  CategoriesState copyWith({
    Maybe<List<MyCategory>> categories,
    Maybe<List<MySubcategory>> subcategories,
  }) {
    return CategoriesState(
      categories: categories.isNone ? this.categories : categories,
      subcategories: subcategories.isNone ? this.subcategories : subcategories,
    );
  }

  @override
  List<Object> get props => [categories.value, subcategories.value];

  @override
  bool get stringify => true;
}
