import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../env.dart';
import '../../store/actions/logs_actions.dart';
import '../../store/actions/settings_actions.dart';
import '../../utils/db_consts.dart';
import '../categories_model/app_category/app_category.dart';
import 'edit_category_dialog.dart';

Future<dynamic> getLogAddEditCategoryDialog({required AppCategory category}) {
  return Get.dialog(
    EditCategoryDialog(
      save: (name, emojiChar, unused) => {
        Env.store.dispatch(LogAddEditCategory(
            category: category.copyWith(name: name, emojiChar: emojiChar))),
      },

      //TODO default function
      /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/

      delete: () => {
        Env.store.dispatch(LogDeleteCategory(category: category)),
        Get.back(),
      },
      category: category,
      categoryOrSubcategory: CategoryOrSubcategory.category,
    ),
  );
}

Future<dynamic> getLogAddEditSubcategoryDialog(
    {required AppCategory subcategory,
    required List<AppCategory?> categories}) {
  return Get.dialog(
    EditCategoryDialog(
      categories: categories,
      save: (name, emojiChar, parentCategoryId) => {
        Env.store.dispatch(LogAddEditSubcategory(
            subcategory: subcategory.copyWith(
                name: name,
                emojiChar: emojiChar,
                parentCategoryId: parentCategoryId))),
      },

      //TODO default function

      delete: () => {
        Env.store.dispatch(LogDeleteSubcategory(subcategory: subcategory)),
        Get.back(),
      },
      initialParent: subcategory.parentCategoryId,
      category: subcategory,
      categoryOrSubcategory: CategoryOrSubcategory.subcategory,
    ),
  );
}

Future<dynamic> getSettingsAddEditCategoryDialog(
    {required AppCategory category}) {
  return Get.dialog(
    EditCategoryDialog(
      save: (name, emojiChar, unused) => {
        Env.store.dispatch(SettingsAddEditCategory(
            category: category.copyWith(name: name, emojiChar: emojiChar))),
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

Future<dynamic> getSettingsAddEditSubcategoryDialog(
    {required AppCategory subcategory,
    required List<AppCategory?> categories}) {
  return Get.dialog(
    EditCategoryDialog(
      categories: categories,
      save: (name, emojiChar, parentCategoryId) => {
        Env.store.dispatch(SettingsAddEditSubcategory(
            subcategory: subcategory.copyWith(
                name: name,
                emojiChar: emojiChar,
                parentCategoryId: parentCategoryId))),
      },
      //TODO default function
      delete: () => {
        Env.store.dispatch(SettingsDeleteSubcategory(subcategory: subcategory))
      },
      category: subcategory,
      categoryOrSubcategory: CategoryOrSubcategory.subcategory,
    ),
  );
}
