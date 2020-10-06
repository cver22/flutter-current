import 'package:expenses/env.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/categories/category_list_dialog.dart';
import 'package:expenses/screens/categories/category_list_tile.dart';
import 'package:expenses/screens/categories/subcategories/subcategory_list_dialog.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class NewCategoryListDialog extends StatelessWidget {
  final String catOrSubDialog;
  final List<MyCategory> categories;
  final List<MySubcategory> subcategories;
  final VoidCallback backChevron;
  final Log log;

  NewCategoryListDialog(
      {Key key, @required this.catOrSubDialog, this.categories, this.subcategories, this.backChevron, this.log})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyCategory> _categories = [];
    // ignore: unused_local_variable
    List<MySubcategory> _subcategories = [];

    //determines which list is passed based on if it comes from default or the entry
    //TODO also make this work to edit the categories directly from a log screen
    if (log != null && catOrSubDialog == CATEGORY) {
      _categories = log.categories;
    } else if (log != null && catOrSubDialog == SUBCATEGORY) {
      _subcategories = log.subcategories
          .where((element) => element.parentCategoryId == Env.store.state.entriesState.selectedEntry.value.category)
          .toList();
    } else {
      _categories = categories;
      _subcategories = subcategories;
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
                catOrSubDialog,
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

  // TODO *****START HERE ********  build on press methods for editing purposes for each list

  ListView _entryCategoryListView(
      List<MyCategory> _categories, List<MySubcategory> _subcategories, BuildContext context) {
    return ListView(
        shrinkWrap: true,
        //TODO implement onReorder
        children: catOrSubDialog == SUBCATEGORY
            ? _subcategoryList(_subcategories, context)
            : categoryList(_categories, context));
  }

  List<CategoryListTile> categoryList(List<MyCategory> _categories, BuildContext context) {
    return _categories
        .map((MyCategory category) => CategoryListTile(
            category: category,
            onTap: () {
              Env.store.dispatch(ChangeEntryCategories(category: category.id));

              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (_) => SubcategoryListDialog(
                  backChevron: () => {
                    Navigator.of(context).pop(),
                    showDialog(
                      context: context,
                      builder: (_) => CategoryListDialog(),
                    ),
                  },
                ),
              );
            }))
        .toList();
  }

  List<CategoryListTile> _subcategoryList(List<MySubcategory> _subcategories, BuildContext context) {
    return _subcategories
        .map((MySubcategory subcategory) => CategoryListTile(
            category: subcategory,
            onTap: () {
              Env.store.dispatch(UpdateSelectedEntry(subcategory: subcategory.id));
              Navigator.of(context).pop();
            }))
        .toList();
  }
}
