import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tile.dart';
import 'package:expenses/categories/categories_screens/edit_category_dialog.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/store/actions/my_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class EntryCategoryListDialog extends StatelessWidget {
  final VoidCallback backChevron;
  final CategoryOrSubcategory categoryOrSubcategory;

  const EntryCategoryListDialog({Key key, this.backChevron, this.categoryOrSubcategory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyCategory> categories;
    return ConnectState(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (singleEntryState) {
          if (categoryOrSubcategory == CategoryOrSubcategory.category) {
            categories = List.from(singleEntryState.categories);
          } else {
            categories = List.from(singleEntryState.subcategories);
            categories.retainWhere((subcategory) =>
                subcategory.parentCategoryId == Env.store.state.singleEntryState.selectedEntry.value.categoryId);
          }

          return buildDialog(context: context, categories: categories, singleEntryState: singleEntryState);
        });
  }

  Widget buildDialog({singleEntryState, BuildContext context, List<MyCategory> categories}) {
    return Dialog(
      elevation: DIALOG_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DIALOG_BORDER_RADIUS)),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                //if no back action is passed, automatically set to pop context
                onPressed: backChevron ?? () => Get.back(),
              ),
              Text(
                categoryOrSubcategory == CategoryOrSubcategory.category ? CATEGORY : SUBCATEGORY,
                //TODO currently uses the database constants to label the dialog, will need to change to if function that utilizes the constants to trigger the UI constants
                style: TextStyle(fontSize: 20.0),
              ),
              _displayAddButton(selectedEntry: singleEntryState.selectedEntry.value)
            ],
          ),
          //shows this list view if the category list comes from the log
          categories.length > 0 ? _categoryListView(context: context, categories: categories) : EmptyContent(),
        ],
      ),
    );
  }

  Widget _displayAddButton({MyEntry selectedEntry}) {
    MyCategory category = MyCategory();
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => categoryOrSubcategory == CategoryOrSubcategory.category
          ? _entryAddEditCategory(category: category)
          : _entryAddEditSubcategory(subcategory: category),
    );
  }

  Widget _categoryListView({BuildContext context, List<MyCategory> categories}) {
    return Expanded(
      flex: 1,
      child: ReorderableListView(
          scrollController: PrimaryScrollController.of(context) ?? ScrollController(),
          onReorder: (oldIndex, newIndex) {
            //reorder for categories
            if (categoryOrSubcategory == CategoryOrSubcategory.category) {
              Env.store.dispatch(ReorderCategoriesFromEntryScreen(oldIndex: oldIndex, newIndex: newIndex));
            } else {
              Env.store.dispatch(ReorderSubcategoriesFromEntryScreen(
                  newIndex: newIndex, oldIndex: oldIndex, reorderedSubcategories: categories));
            }
          },
          children: _categoryList(context: context, categories: categories)),
    );
  }

  List<CategoryListTile> _categoryList({List<MyCategory> categories, BuildContext context}) {
    //determine if list is categories or subcategories
    bool isCategory = categoryOrSubcategory == CategoryOrSubcategory.category;
    return categories
        .map(
          (MyCategory category) => CategoryListTile(
            key: Key(category.id),
            category: category,
            onTapEdit: () => isCategory
                ? _entryAddEditCategory(category: category)
                : _entryAddEditSubcategory(subcategory: category),
            onTap: () =>
                isCategory ? _entrySelectCategory(category: category) : _entrySelectSubcategory(subcategory: category),
          ),
        )
        .toList();
  }

  Future<dynamic> _entryAddEditCategory({@required MyCategory category}) {
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, unused) => Env.store
            .dispatch(AddEditCategoryFromEntryScreen(category: category.copyWith(name: name, emojiChar: emojiChar))),

        /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/

        delete: () => {
          Env.store.dispatch(DeleteCategoryFromEntryScreen(category: category)),
          Get.back(),
        },
        category: category,
        categoryOrSubcategory: CategoryOrSubcategory.category,
      ),
    );
  }

  Future<dynamic> _entrySelectCategory({@required MyCategory category}) {
    Env.store.dispatch(UpdateEntryCategory(newCategory: category.id));
    Get.back();
    if(_entryHasSubcategories(category: category)) {
      return Get.dialog(
        EntryCategoryListDialog(
          categoryOrSubcategory: CategoryOrSubcategory.subcategory,
          key: ExpenseKeys.subcategoriesDialog,
          backChevron: () => {
            Get.back(),
            Get.dialog(
              EntryCategoryListDialog(
                categoryOrSubcategory: CategoryOrSubcategory.category,
                key: ExpenseKeys.categoriesDialog,
              ),
            ),
          },
        ),
      );
    }

    return null;

  }

  Future<dynamic> _entryAddEditSubcategory({@required MyCategory subcategory}) {
    return Get.dialog(
      EditCategoryDialog(
        categories: Env.store.state.singleEntryState.categories,
        save: (name, emojiChar, parentCategoryId) => {
          Env.store.dispatch(AddEditSubcategoryFromEntryScreen(
              subcategory: subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId))),
        },

        //TODO default function

        delete: () => {
          Env.store.dispatch(DeleteSubcategoryFromEntryScreen(subcategory: subcategory)),
          Get.back(),
        },
        initialParent: Env.store.state.singleEntryState.selectedEntry.value.categoryId,
        category: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }

  Future<void> _entrySelectSubcategory({@required MyCategory subcategory}) async {
    //onTap method for Entry Subcategories
    Env.store.dispatch(UpdateEntrySubcategory(subcategory: subcategory.id));
    Get.back();
  }

  bool _entryHasSubcategories({@required MyCategory category}){
    if(category.id == NO_CATEGORY || category.id == TRANSFER_FUNDS) {
      return false;
    }
    return true;

  }


}
