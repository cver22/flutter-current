import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tools.dart';
import 'package:expenses/categories/categories_screens/master_category_drag_and_drop_list.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MasterCategoryListDialog extends StatelessWidget {
  final SettingsLogFilter setLogFilter;

  const MasterCategoryListDialog({Key key, @required this.setLogFilter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<AppCategory> categories = [];
    List<AppCategory> subcategories = [];

    if (setLogFilter == SettingsLogFilter.log) {
      return ConnectState(
        where: notIdentical,
        map: (logsState) => logsState.logsState,
        builder: (state) {
          print('Rendering Log Category Dialog');
          Log log = state.selectedLog.value;

          return _buildDialog(categories: log.categories, subcategories: log.subcategories);
        },
      );
    } else if (setLogFilter == SettingsLogFilter.settings) {
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
    } else if (setLogFilter == SettingsLogFilter.filter) {
      return ConnectState(
        where: notIdentical,
        map: (state) => state.entriesFilterState,
        builder: (filterState) {
          print('Rendering Filter Category Dialog');
          EntriesFilter filter = filterState.entriesFilter.value;
          categories = filter.allCategories;
          subcategories = filter.allSubcategories;

          return _buildDialog(
            categories: categories,
            subcategories: subcategories,
            selectedSubcategories: filter.selectedSubcategories,
            selectedCategories: filter.selectedCategories,
          );
        },
      );
    } else {
      return ErrorContent();
    }
  }

  Widget _buildDialog(
      {@required List<AppCategory> categories,
      @required List<AppCategory> subcategories,
      Map<String, bool> selectedCategories,
      Map<String, bool> selectedSubcategories}) {
    return AppDialog(

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
              setLogFilter == SettingsLogFilter.filter ? Container() : _displayAddButton(),
            ],
          ),
          //shows this list view if the category list comes from the log
          categories.length > 0
              ? Expanded(
                  child: MasterCategoryDragAndDropList(
                    selectedCategories: selectedCategories,
                    selectedSubcategories: selectedSubcategories,
                    categories: categories,
                    subcategories: subcategories,
                    setLogFilter: setLogFilter,
                  ),
                )
              : EmptyContent(),
          //TODO this should direct the user where to add a category if they have deleted all of them
        ],
      ),
    );
  }

  Widget _displayAddButton() {
    AppCategory category = AppCategory();
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => {
        if (setLogFilter == SettingsLogFilter.log)
          {
            getLogAddEditCategoryDialog(category: category),
          }
        else if (setLogFilter == SettingsLogFilter.settings)
          {getSettingsAddEditCategoryDialog(category: category)}
        else
          {
            ErrorContent(),
          }
      },
    );
  }
}
