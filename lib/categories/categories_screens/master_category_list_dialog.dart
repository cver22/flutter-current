import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/edit_category_dialog.dart';
import 'package:expenses/categories/categories_screens/master_category_drag_and_drop_list.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class MasterCategoryListDialog extends StatelessWidget {
  const MasterCategoryListDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState(
        where: notIdentical,
        map: (state) => state.logsState,
        builder: (logState) {
          Log log = logState.selectedLog.value;

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
                Container(
                  //TODO this needs a more elegant method of keeping the bound of the list
                  height: 600.0,
                  child: log.categories.length > 0 ? MasterCategoryDragAndDropList(log: log) : EmptyContent(),
                ),
              ],
            ),
          );
        });
  }

  Widget _displayAddButton() {
    MyCategory category = MyCategory();
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => _logAddEditCategory(category: category),
    );
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
