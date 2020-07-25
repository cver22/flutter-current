part of 'actions.dart';

class UpdateCategoriesStatus implements Action {
  final Maybe<List<MyCategory>> categories;
  final Maybe<List<MySubcategory>> subcategories;

  UpdateCategoriesStatus({this.categories, this.subcategories});

  @override
  AppState updateState(AppState categoriesState) {

    Maybe<List<MyCategory>> updateCategories;
    Maybe<List<MySubcategory>> updateSubcategories;

    if(categories == null) {
      updateCategories = Maybe.none() ;
    }else{
      updateCategories = categories;
    }

    if(subcategories == null) {
      updateSubcategories = Maybe.none();
    }else{
      updateSubcategories = subcategories;
    }

    return categoriesState.copyWith(
        categoriesState: categoriesState.categoriesState
            .copyWith(categories: updateCategories, subcategories: updateSubcategories));
  }
}
/*TODO StartHere - not sure if I can use maybe of a list, I should be able to considering i can use it for classes
*  how do I make it work?*/
