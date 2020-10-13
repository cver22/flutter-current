import 'package:expenses/env.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/models/settings/settings.dart';
import 'package:expenses/screens/categories/category_list_tile.dart';
import 'package:expenses/screens/categories/edit_category_dialog.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//This widget is used in all category and subcategory lists throughout the application
//by choosing setting or not, the widget automatically decides how to act

class NewCategoryListDialog extends StatelessWidget {
  final CategoryOrSubcategory categoryOrSubcategory;
  final bool editSettings; //automatically set to false if not set
  final bool editLogDefaults;
  final VoidCallback backChevron;
  final Log log;

  NewCategoryListDialog(
      {Key key,
      @required this.categoryOrSubcategory,
      this.editSettings = false,
      this.editLogDefaults,
      this.backChevron,
      this.log})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyCategory> _categories = [];
    List<MySubcategory> _subcategories = [];

    //determines which list is passed based on if it comes from default or the entry
    //TODO also make this work to edit the categories directly from a log screen
    if (log != null && categoryOrSubcategory == CategoryOrSubcategory.category) {
      _categories = log.categories;
    } else if (log != null && categoryOrSubcategory == CategoryOrSubcategory.subcategory) {
      _subcategories = log.subcategories
          .where((element) => element.parentCategoryId == Env.store.state.entriesState.selectedEntry.value.category)
          .toList();
    } else {
      Settings _settings = Env.store.state.settingsState.settings.value;
      _categories = _settings.defaultCategories;
      _subcategories = _settings.defaultSubcategories;
    }

    return Dialog(
      //TODO move to constants
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),

      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                //if no back action is passed, automatically set to pop context
                onPressed: () => backChevron ?? Navigator.pop(context),
              ),
              Text(
                categoryOrSubcategory == CategoryOrSubcategory.category ? CATEGORY : SUBCATEGORY,
                //TODO currently uses the database constants to label the dialog, will need to change to if function that utilizes the constants to trigger the UI constants
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
          //shows this list view if the category list comes from the log
          _entryCategoryListView(_categories, _subcategories, context),
        ],
      ),
    );
  }

  // TODO *****START HERE ********  build on tap methods for editing purposes for each list

  ListView _entryCategoryListView(
      List<MyCategory> _categories, List<MySubcategory> _subcategories, BuildContext context) {
    return ListView(
        shrinkWrap: true,
        //TODO implement onReorder
        children: categoryOrSubcategory == CategoryOrSubcategory.subcategory
            ? _subcategoryList(_subcategories, context)
            : categoryList(_categories, context));
  }

  List<CategoryListTile> categoryList(List<MyCategory> _categories, BuildContext context) {
    return _categories
        .map((MyCategory category) => CategoryListTile(
            category: category,
            onLongPress: () {
              showDialog(
                context: context,
                builder: (_) => EditCategoryDialog(
                  category: category,
                  categoryOrSubcategory: CategoryOrSubcategory.category,
                ),
              );
            },
            onTap: () {
              Env.store.dispatch(ChangeEntryCategories(category: category.id));
              //TODO change dialogues to a named route so that Get.offNamedUntil named route can be used to navigate back from the subcategories
              Get.back();
              Get.dialog(
                NewCategoryListDialog(
                  categoryOrSubcategory: CategoryOrSubcategory.subcategory,
                  log: log,
                  key: ExpenseKeys.subcategoriesDialog,
                ),
              );

              /*Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (_) => NewCategoryListDialog(
                  categoryOrSubcategory: CategoryOrSubcategory.subcategory,
                  log: log,
                  key: ExpenseKeys.subcategoriesDialog,
                ),
              );*/
            }))
        .toList();
  }

  List<CategoryListTile> _subcategoryList(List<MySubcategory> _subcategories, BuildContext context) {
    return _subcategories
        .map((MySubcategory subcategory) => CategoryListTile(
            category: subcategory,
            onTap: () {
              Env.store.dispatch(UpdateSelectedEntry(subcategory: subcategory.id));
              Get.back();
            }))
        .toList();
  }

  List<CategoryListTile> settingsCategoryList(List<MyCategory> _categories, BuildContext context) {
    return _categories
        .map((MyCategory category) => CategoryListTile(
            category: category,
            onTap: () {
              //Env.store.dispatch(ChangeEntryCategories(category: category.id));
            }))
        .toList();
  }
}
