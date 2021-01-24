import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/edit_category_dialog.dart';
import 'package:expenses/categories/categories_screens/master_category_list_tile.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class MasterCategoryListDialog extends StatelessWidget {
  final Log log;

  const MasterCategoryListDialog({Key key, @required this.log}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => Get.back(),
              ),
              Text(
                CATEGORY,
                //TODO currently uses the database constants to label the dialog, will need to change to if function that utilizes the constants to trigger the UI constants
                style: TextStyle(fontSize: 20.0),
              ),
              _displayAddButton(),
            ],
          ),
          //shows this list view if the category list comes from the log
          log.categories.length > 0 ? _categoryListView(context: context, log: log) : EmptyContent(),
        ],
      ),
    );
  }

  Widget _displayAddButton() {
    MyCategory category = MyCategory();
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => _logAddEditCategory(category: category),
    );
  }

  Widget _categoryListView({BuildContext context, @required Log log}) {
    return Expanded(
      flex: 1,
      child: ReorderableListView(
          scrollController: PrimaryScrollController.of(context) ?? ScrollController(),
          onReorder: (oldIndex, newIndex) {
            //TODO implement onReorder
          },
          children: _categoryList(context: context, log: log)),
    );
  }

  List<MasterCategoryListTile> _categoryList({BuildContext context, @required Log log}) {
    return log.categories
        .map((MyCategory category) => MasterCategoryListTile(
              key: Key(category.id),
              category: category,
              subcategories: List.from(log.subcategories),
              onTapEdit: null,
              onTap: null,
            ))
        .toList();
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
}
