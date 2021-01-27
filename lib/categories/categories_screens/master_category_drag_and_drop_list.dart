import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:expenses/categories/categories_screens/category_list_tile_components.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tile.dart';
import 'package:expenses/categories/categories_screens/edit_category_dialog.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class MasterCategoryDragAndDropList extends StatelessWidget {
  final Log log;

  const MasterCategoryDragAndDropList({Key key, @required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('build drag and drop');
    return DragAndDropLists(
      children: List.generate(log.categories.length, (index) => _buildList(index)),
      onItemReorder: _onItemReorder,
      onListReorder: _onListReorder,
      // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
      listGhost: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 100.0),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Icon(Icons.add_box),
          ),
        ),
      ),
    );
  }

  _buildList(int outerIndex) {
    MyCategory category = log.categories[outerIndex];
    List<MyCategory> subcategories = List.from(log.subcategories);
    subcategories.retainWhere((subcategory) => subcategory.parentCategoryId == category.id);
    return DragAndDropListExpansion(
      title: Text(category.name),
      leading: CategoryListTileLeading(category: category),
      trailing: CategoryListTileTrailing(onTapEdit: () => _logAddEditCategory(category: category),),
      children: List.generate(subcategories.length, (index) => _buildItem(subcategory: subcategories[index])),
      listKey: ObjectKey(subcategories),
    );
  }

  _buildItem({MyCategory subcategory}) {
    return DragAndDropItem(
        child: CategoryListTile(
          onTapEdit: () => _logAddEditSubcategory(subcategory: subcategory),
      category: subcategory,
    ));
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    //TODO create on reorder method for subcategories
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    //TODO create on reorder method for categories
  }

  Future<dynamic> _logAddEditCategory({@required MyCategory category}) {
    return Get.dialog(
      EditCategoryDialog(
        save: (name, emojiChar, unused) => {
          Env.store.dispatch(AddEditCategoryFromLog(category: category.copyWith(name: name, emojiChar: emojiChar))),
        },

        /*setDefault: (category) => {
          Env.logsFetcher.updateLog(log.setCategoryDefault(log: log, category: category)),
        },*/

        delete: () => {
          Env.store.dispatch(DeleteCategoryFromLog(category: null)),
          Get.back(),
        },
        category: category,
        categoryOrSubcategory: CategoryOrSubcategory.category,
      ),
    );
  }

  Future<dynamic> _logAddEditSubcategory({@required MyCategory subcategory}) {
    return Get.dialog(
      EditCategoryDialog(
        categories: Env.store.state.logsState.selectedLog.value.categories,
        save: (name, emojiChar, parentCategoryId) => {
          Env.store.dispatch(AddEditSubcategoryFromLog(
              subcategory: subcategory.copyWith(name: name, emojiChar: emojiChar, parentCategoryId: parentCategoryId))),
        },

        //TODO default function

        delete: () => {
          Env.store.dispatch(DeleteSubcategoryFromLog(subcategory: subcategory)),
          Get.back(),
        },
        initialParent: subcategory.parentCategoryId,
        category: subcategory,
        categoryOrSubcategory: CategoryOrSubcategory.subcategory,
      ),
    );
  }
}
