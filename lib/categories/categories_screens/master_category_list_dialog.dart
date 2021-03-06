import 'package:expenses/app/common_widgets/app_dialog.dart';
import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tools.dart';
import 'package:expenses/categories/categories_screens/master_category_drag_and_drop_list.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

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
        map: (state) => state.logsState,
        builder: (logsState) {

          Log log = logsState.selectedLog.value;

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
        map: (state) => state.filterState,
        builder: (filterState) {
          print('Rendering Filter Category Dialog');
          Filter filter = filterState.filter.value;
          categories = filterState.consolidatedCategories;
          subcategories = filterState.consolidatedSubcategories;

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
      List<String> selectedCategories,
      List<String> selectedSubcategories}) {
    return AppDialog(
      trailingTitleWidget: setLogFilter == SettingsLogFilter.filter ? Container() : _displayAddButton(),
      title: CATEGORY,
      child: categories.length > 0
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
