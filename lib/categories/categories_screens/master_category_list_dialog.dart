import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tools.dart';
import 'package:expenses/categories/categories_screens/master_category_drag_and_drop_list.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MasterCategoryListDialog extends StatelessWidget {
  final SettingsLogEntry setLogEnt;

  const MasterCategoryListDialog({Key key, @required this.setLogEnt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyCategory> categories = [];
    List<MyCategory> subcategories = [];

    if (setLogEnt == SettingsLogEntry.log) {
      return ConnectState(
        where: notIdentical,
        map: (state) => state.logsState,
        builder: (state) {
          print('Rendering Log Category Dialog');
          Log log = state.selectedLog.value;
          categories = log.categories;
          subcategories = log.subcategories;

          return _buildDialog(categories: categories, subcategories: subcategories);
        },
      );
    } else if (setLogEnt == SettingsLogEntry.settings) {
      return ConnectState(
        where: notIdentical,
        map: (state) => state.settingsState,
        builder: (state) {
          print('Rendering Settings Category Dialog');
          Settings settings = state.settingsState.settings.value;
          categories = settings.defaultCategories;
          subcategories = settings.defaultSubcategories;

          return _buildDialog(categories: categories, subcategories: subcategories);
        },
      );
    } else {
      return ErrorContent();
    }
  }

  Widget _buildDialog({@required List<MyCategory> categories, @required List<MyCategory> subcategories}) {
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
            child: categories.length > 0
                ? MasterCategoryDragAndDropList(
                    categories: categories,
                    subcategories: subcategories,
                    setLogEnt: setLogEnt,
                  )
                : EmptyContent(),
          ),
        ],
      ),
    );
  }

  Widget _displayAddButton() {
    MyCategory category = MyCategory();
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => {
        if (setLogEnt == SettingsLogEntry.log)
          {
            getLogAddEditCategoryDialog(category: category),
          }
        else if (setLogEnt == SettingsLogEntry.settings)
          {getSettingsAddEditCategoryDialog(category: category)}
        else
          {
            ErrorContent(),
          }
      },
    );
  }
}
