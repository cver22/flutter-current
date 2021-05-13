import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_dialog.dart';
import '../../app/common_widgets/empty_content.dart';
import '../../app/common_widgets/error_widget.dart';
import '../../env.dart';
import '../../filter/filter_model/filter.dart';
import '../../log/log_model/log.dart';
import '../../settings/settings_model/settings.dart';
import '../../store/actions/filter_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/db_consts.dart';
import '../../utils/utils.dart';
import '../categories_model/app_category/app_category.dart';
import 'category_list_tools.dart';
import 'master_category_drag_and_drop_list.dart';

class MasterCategoryListDialog extends StatelessWidget {
  final SettingsLogFilterEntry setLogFilter;

  const MasterCategoryListDialog({Key? key, required this.setLogFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<AppCategory> categories = [];
    List<AppCategory> subcategories = [];

    if (setLogFilter == SettingsLogFilterEntry.log) {
      return ConnectState(
        where: notIdentical,
        map: (state) => state.logsState,
        builder: (dynamic logsState) {
          Log log = logsState.selectedLog.value;

          return _buildDialog(
              categories: log.categories, subcategories: log.subcategories);
        },
      );
    } else if (setLogFilter == SettingsLogFilterEntry.settings) {
      return ConnectState(
        where: notIdentical,
        map: (state) => state.settingsState,
        builder: (dynamic settingsState) {
          print('Rendering Settings Category Dialog');
          Settings settings = settingsState.settings.value;
          categories = settings.defaultCategories;
          subcategories = settings.defaultSubcategories;


          return _buildDialog(
              categories: categories, subcategories: subcategories);
        },
      );
    } else if (setLogFilter == SettingsLogFilterEntry.filter) {
      return ConnectState(
        where: notIdentical,
        map: (state) => state.filterState,
        builder: (dynamic filterState) {
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
      {required List<AppCategory> categories,
      required List<AppCategory> subcategories,
      List<String>? selectedCategories,
      List<String>? selectedSubcategories}) {
    return AppDialogWithActions(
      trailingTitleWidget:
          setLogFilter == SettingsLogFilterEntry.filter ? null : _displayAddButton(),
      title: CATEGORY,
      actions: setLogFilter == SettingsLogFilterEntry.filter ? _actions() : null,
      child: MasterCategoryDragAndDropList(
              selectedCategories: selectedCategories,
              selectedSubcategories: selectedSubcategories,
              categories: categories,
              subcategories: subcategories,
              setLogFilter: setLogFilter,
      ),
    );
  }

  Widget _displayAddButton() {
    AppCategory category = AppCategory();
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () => {
        if (setLogFilter == SettingsLogFilterEntry.log)
          {
            getLogAddEditCategoryDialog(category: category),
          }
        else if (setLogFilter == SettingsLogFilterEntry.settings)
          {getSettingsAddEditCategoryDialog(category: category)}
        else
          {
            ErrorContent(),
          }
      },
    );
  }

  List<Widget> _actions() {
    return [
      TextButton(
        child: Text('Clear'),
        onPressed: () {
          Env.store.dispatch(FilterClearCategorySelection());
        },
      ),
      TextButton(
          child: Text('Done'),
          onPressed: () {
            Get.back();
          }),
    ];
  }
}
