import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tile.dart';
import 'package:expenses/categories/categories_screens/edit_category_dialog.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class MasterCategoryListTile extends StatelessWidget {
  final MyCategory category;
  final VoidCallback onTap;
  final VoidCallback onTapEdit;
  final List<MyCategory> subcategories;

  const MasterCategoryListTile({Key key, @required this.category, this.onTap, this.onTapEdit, this.subcategories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    subcategories.retainWhere((subcategory) => subcategory.parentCategoryId == category.id);

    return ExpansionTile(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          category.emojiChar != null
              ? Text(
                  category.emojiChar,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: EMOJI_SIZE),
                )
              : Text(
                  '\u{2757}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: EMOJI_SIZE),
                ),
          Text(category.name),
        ],
      ),
      children: [

        _buildSubcategoryListView(subcategories: subcategories)
      ],
      trailing: _displayAddButton(parentCategoryId: category.id),
    );
  }

  Widget _buildSubcategoryListView({List<MyCategory> subcategories}) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: _subcategoryList(subcategories: subcategories),
      /*onReorder: (oldIndex, newIndex) {
        //TODO implement onReorder
      },*/
    );
  }

  List<CategoryListTile> _subcategoryList({@required List<MyCategory> subcategories, BuildContext context}) {
    return subcategories
        .map(
          (MyCategory subcategory) => CategoryListTile(
              key: Key(subcategory.id),
              category: subcategory,
              onTapEdit: () => {_logAddEditSubcategory(subcategory: subcategory)}),
        )
        .toList();
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

  Widget _displayAddButton({String parentCategoryId}) {
    //add button is displayed in all cases except where the parent category is "No Category"
    if (parentCategoryId != null && parentCategoryId == NO_CATEGORY) {
      return IconButton(icon: Container(), onPressed: null);
    } else {
      MyCategory category = MyCategory(parentCategoryId: parentCategoryId);
      return IconButton(
        icon: Icon(Icons.add),
        onPressed: () => _logAddEditSubcategory(subcategory: category),
      );
    }
  }
}
