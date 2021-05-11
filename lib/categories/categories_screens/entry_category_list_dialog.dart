import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_dialog.dart';
import '../../app/common_widgets/empty_content.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../env.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/db_consts.dart';
import '../../utils/keys.dart';
import '../../utils/utils.dart';
import '../categories_model/app_category/app_category.dart';
import 'category_list_tile.dart';
import 'edit_category_dialog.dart';

class EntryCategoryListDialog extends StatelessWidget {
  final VoidCallback? backChevron;
  final CategoryOrSubcategory categoryOrSubcategory;

  const EntryCategoryListDialog(
      {Key? key, this.backChevron, required this.categoryOrSubcategory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<AppCategory> categories;
    return ConnectState(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (dynamic singleEntryState) {
          if (categoryOrSubcategory == CategoryOrSubcategory.category) {
            categories = List.from(singleEntryState.categories);
          } else {
            categories = List.from(singleEntryState.subcategories);
            categories.retainWhere((subcategory) =>
                subcategory.parentCategoryId ==
                Env.store.state.singleEntryState.selectedEntry.value
                    .categoryId);
          }

          return buildDialog(
              context: context,
              categories: categories,
              singleEntryState: singleEntryState);
        });
  }

  Widget buildDialog(
      {required singleEntryState, BuildContext? context, required List<AppCategory> categories}) {
    return AppDialogWithActions(
      padContent: false,
      title: categoryOrSubcategory == CategoryOrSubcategory.category
          ? CATEGORY
          : SUBCATEGORY,
      backChevron: backChevron,
      trailingTitleWidget: _displayAddButton(
          selectedEntry: singleEntryState.selectedEntry.value),
      child: categories.length > 0
          ? _categoryListView(context: context!, categories: categories)
          : EmptyContent(),
    );
  }

  Widget _displayAddButton({AppEntry? selectedEntry}) {
    AppCategory category = AppCategory();
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => categoryOrSubcategory == CategoryOrSubcategory.category
          ? _entryAddEditCategory(category: category)
          : _entryAddEditSubcategory(subcategory: category),
    );
  }

  Widget _categoryListView(
      {required BuildContext context, required List<AppCategory> categories}) {
    return ReorderableListView(
        scrollController:
            PrimaryScrollController.of(context) ?? ScrollController(),
        onReorder: (oldIndex, newIndex) {
          //reorder for categories
          if (categoryOrSubcategory == CategoryOrSubcategory.category) {
            Env.store.dispatch(
                EntryReorderCategories(oldIndex: oldIndex, newIndex: newIndex));
          } else {
            Env.store.dispatch(EntryReorderSubcategories(
                newIndex: newIndex,
                oldIndex: oldIndex,
                reorderedSubcategories: categories));
          }
        },
        children: _categoryList(context: context, categories: categories));
  }

  List<CategoryListTile> _categoryList(
      {required List<AppCategory> categories, BuildContext? context}) {
    //determine if list is categories or subcategories
    bool isCategory = categoryOrSubcategory == CategoryOrSubcategory.category;
    return categories
        .map(
          (AppCategory category) => CategoryListTile(
            setLogFilter: SettingsLogFilterEntry.entry,
            key: Key(category.id!),
            category: category,
            onTapEdit: () => isCategory
                ? _entryAddEditCategory(category: category)
                : _entryAddEditSubcategory(subcategory: category),
            onTap: () => isCategory
                ? _entrySelectCategory(category: category)
                : _entrySelectSubcategory(subcategory: category),
          ),
        )
        .toList();
  }

  Future<dynamic> _entryAddEditCategory({required AppCategory category}) {
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, unused) {
          Env.store.dispatch(EntryAddEditCategory(
              category: category.copyWith(name: name, emojiChar: emojiChar)));
        },

        /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/

        delete: () => {
          Env.store.dispatch(EntryDeleteCategory(category: category)),
          Get.back(),
        },
        category: category,
        categoryOrSubcategory: CategoryOrSubcategory.category,
      ),
    );
  }

  Future<dynamic>? _entrySelectCategory({required AppCategory category}) {
    Env.store.dispatch(EntrySelectCategory(newCategoryId: category.id!));
    Get.back();
    if (_entryHasSubcategories(category: category)) {
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

  Future<dynamic> _entryAddEditSubcategory(
      {required AppCategory subcategory}) {
    return Get.dialog(
      EditCategoryDialog(
        categories: Env.store.state.singleEntryState.categories,
        save: (name, emojiChar, parentCategoryId) => {
          Env.store.dispatch(EntryAddEditSubcategory(
              subcategory: subcategory.copyWith(
                  name: name,
                  emojiChar: emojiChar,
                  parentCategoryId: parentCategoryId))),
        },

        //TODO default function

        delete: () => {
          Env.store.dispatch(EntryDeleteSubcategory(subcategory: subcategory)),
          Get.back(),
        },
        initialParent:
            Env.store.state.singleEntryState.selectedEntry.value.categoryId,
        category: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }

  Future<void> _entrySelectSubcategory(
      {required AppCategory subcategory}) async {
    //onTap method for Entry Subcategories
    Env.store.dispatch(EntrySelectSubcategory(subcategory: subcategory.id!));
    Get.back();
  }

  bool _entryHasSubcategories({required AppCategory category}) {
    if (category.id == NO_CATEGORY || category.id == TRANSFER_FUNDS) {
      return false;
    }
    return true;
  }
}
