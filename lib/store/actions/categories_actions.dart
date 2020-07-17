part of 'actions.dart';

class UpdateCategoriesStatus implements Action {
  final Maybe<List<MyCategory>> categories;
  final Maybe<List<MySubcategory>> subcategories;

  UpdateCategoriesStatus({this.categories, this.subcategories});

  @override
  AppState updateState(AppState categoriesState) {

    return categoriesState.copyWith(
        categoriesState: categoriesState.categoriesState
            .copyWith(categories: categories ?? Maybe.none(), subcategories: subcategories ?? Maybe.none()));
  }
}
/*TODO StartHere - not sure if I can use maybe of a list, I should be able to considering i can use it for classes
*  how do I make it work?*/
