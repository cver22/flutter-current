import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
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
    List<AppCategory> categories = [];
    List<AppCategory> subcategories = [];

    if (setLogEnt == SettingsLogEntry.log) {
      return ConnectState(
        where: notIdentical,
        map: (logsState) => logsState.logsState,
        builder: (state) {
          print('Rendering Log Category Dialog');
          Log log = state.selectedLog.value;

          return _buildDialog(categories: log.categories, subcategories: log.subcategories);
        },
      );
    } else if (setLogEnt == SettingsLogEntry.settings) {
      return ConnectState(
        where: notIdentical,
        map: (state) => state.settingsState,
        builder: (settingsState) {
          print('Rendering Settings Category Dialog');
          Settings settings = settingsState.settings.value;
          categories = settings.defaultCategories;
          subcategories = settings.defaultSubcategories;

          return _buildDialog(categories: categories, subcategories: subcategories);
        },
      );
    } else {
      return ErrorContent();
    }
  }

  Widget _buildDialog({@required List<AppCategory> categories, @required List<AppCategory> subcategories}) {
    return Dialog(
      insetPadding: EdgeInsets.all(30),
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
          categories.length > 0
              ? Expanded(
            child: MasterCategoryDragAndDropList(
              categories: categories,
              subcategories: subcategories,
              setLogEnt: setLogEnt,
            ),
          )
              : EmptyContent(),
          //TODO this should direct the user where to ass a category if they have deleted all of them
        ],
      ),
    );
  }

  Widget _displayAddButton() {
    AppCategory category = AppCategory();
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
