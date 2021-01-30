import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/edit_category_dialog.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../env.dart';

Future<dynamic> getLogAddEditSubcategoryDialog(
    {@required MyCategory subcategory, @required List<MyCategory> categories}) {
  return Get.dialog(
    EditCategoryDialog(
      categories: categories,
      save: (name, emojiChar, parentCategoryId) =>
      {
        Env.store.dispatch(AddEditSubcategoryFromLog(
            subcategory: subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId))),
      },

      //TODO default function

      delete: () =>
      {
        Env.store.dispatch(DeleteSubcategoryFromLog(subcategory: subcategory)),
        Get.back(),
      },
      initialParent: subcategory.parentCategoryId,
      category: subcategory,
      categoryOrSubcategory: CategoryOrSubcategory.subcategory,
    ),
  );
}

Future<dynamic> getLogAddEditCategoryDialog({@required MyCategory category}) {
  return Get.dialog(
    EditCategoryDialog(
      save: (name, emojiChar, unused) =>
      {
        Env.store.dispatch(AddEditCategoryFromLog(category: category.copyWith(name: name, emojiChar: emojiChar))),
      },

      //TODO default function
      /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/

      delete: () =>
      {
        Env.store.dispatch(DeleteCategoryFromLog(category: category)),
        Get.back(),
      },
      category: category,
      categoryOrSubcategory: CategoryOrSubcategory.category,
    ),
  );
}

Future<dynamic> getSettingsAddEditCategoryDialog({@required MyCategory category}) {
  return Get.dialog(
    EditCategoryDialog(
      save: (name, emojiChar, unused) =>
      {
        Env.store.dispatch(SettingsAddEditCategory(category: category.copyWith(name: name, emojiChar: emojiChar))),
      },

      /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/
      delete: () => {
      Env.store.dispatch(SettingsDeleteCategory(category: category)),
    },
      category: category,
      categoryOrSubcategory: CategoryOrSubcategory.category,
    ),
  );
}

Future<dynamic> getSettingsAddEditSubcategoryDialog({@required MyCategory subcategory, @required List<MyCategory> categories}) {
  return Get.dialog(
    EditCategoryDialog(
      categories: categories,
      save: (name, emojiChar, parentCategoryId) =>
      {
        Env.store.dispatch(SettingsAddEditSubcategory(
            subcategory: subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId))),
      },
      //TODO default function
      delete: () =>
      {
        Env.store.dispatch(SettingsDeleteSubcategory(subcategory: subcategory))
      },
      category: subcategory,
      categoryOrSubcategory: CategoryOrSubcategory.subcategory,
    ),
  );
}