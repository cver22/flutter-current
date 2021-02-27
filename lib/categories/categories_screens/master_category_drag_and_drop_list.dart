import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tile_components.dart';
import 'package:expenses/categories/categories_screens/category_list_tile.dart';
import 'package:expenses/categories/categories_screens/category_list_tools.dart';
import 'package:expenses/store/actions/entries_filter_actions.dart';
import 'package:expenses/store/actions/logs_actions.dart';
import 'package:expenses/store/actions/settings_actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class MasterCategoryDragAndDropList extends StatelessWidget {
  final Map<String, bool> selectedCategories;
  final Map<String, bool> selectedSubcategories;
  final List<AppCategory> categories;
  final List<AppCategory> subcategories;
  final SettingsLogFilter setLogFilter;

  const MasterCategoryDragAndDropList(
      {Key key, @required this.categories, @required this.subcategories, @required this.setLogFilter, this.selectedCategories, this.selectedSubcategories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('build drag and drop');
    return DragAndDropLists(
      children: List.generate(categories.length, (index) => _buildList(outerIndex: index)),
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

  _buildList({@required int outerIndex}) {
    List<bool> expandedCategories = List();
    expandedCategories = setExpandedCategories(expandedCategories);

    AppCategory category = categories[outerIndex];
    List<AppCategory> subs = List.from(subcategories);
    //retain subcategory list based on parent category list
    subs.retainWhere((subcategory) => subcategory.parentCategoryId == category.id);


    return DragAndDropListExpansion(
      canDrag: setLogFilter != SettingsLogFilter.filter,
      initiallyExpanded: expandedCategories[outerIndex],
      onExpansionChanged: (bool) {
        _onExpansionChanged(outerIndex);
      },
      contentsWhenEmpty: _emptyContents(category: category),
      title: Text(category.name),
      leading: CategoryListTileLeading(category: category),
      trailing: _setTrailingIcon(category: category, expandedCategories: expandedCategories, outerIndex: outerIndex),
      children: List.generate(subs.length, (index) => _buildItem(subcategory: subs[index], categories: categories, selected: selectedSubcategories != null ? selectedSubcategories[subs[index].id] : null )),
      listKey: ObjectKey(subs),
    );
  }

  Widget _setTrailingIcon({AppCategory category, List<bool> expandedCategories, int outerIndex}) {

    if (setLogFilter == SettingsLogFilter.filter) {
      return FilterListTileTrailing(onSelect: () => Env.store.dispatch(FilterSelectDeselectCategory(id: category.id)), selected: selectedCategories[category.id]);
    } else {
      return MasterCategoryListTileTrailing(
        categories: categories,
        category: category,
        expanded: expandedCategories[outerIndex],
        setLogFilter: setLogFilter,
      );
    }
  }

  void _onExpansionChanged(int outerIndex) {
    if (setLogFilter == SettingsLogFilter.log) {
      Env.store.dispatch(ExpandCollapseLogCategory(index: outerIndex));
    } else if (setLogFilter == SettingsLogFilter.settings) {
      Env.store.dispatch(ExpandCollapseSettingsCategory(index: outerIndex));
    } else if (setLogFilter == SettingsLogFilter.filter) {
      Env.store.dispatch(FilterExpandCollapseCategory(index: outerIndex));
    }
  }

  List<bool> setExpandedCategories(List<bool> expandedCategories) {
    if (setLogFilter == SettingsLogFilter.log) {
      expandedCategories = List.from(Env.store.state.logsState.expandedCategories);
    } else if (setLogFilter == SettingsLogFilter.settings) {
      expandedCategories = List.from(Env.store.state.settingsState.expandedCategories);
    } else if (setLogFilter == SettingsLogFilter.filter) {
      expandedCategories = List.from(Env.store.state.entriesFilterState.expandedCategories);
    }
    return expandedCategories;
  }

  _buildItem({@required AppCategory subcategory, @required List<AppCategory> categories, bool selected}) {
    return DragAndDropItem(
        canDrag: setLogFilter != SettingsLogFilter.filter,
        child: CategoryListTile(
          inset: true,
          onTapEdit: () {
            _onTapEdit(subcategory, categories);
          },
          category: subcategory,
          setLogFilter: setLogFilter,
          selected: selected,
        ));
  }

  void _onTapEdit(AppCategory subcategory, List<AppCategory> categories) {
    if (setLogFilter == SettingsLogFilter.log) {
      getLogAddEditSubcategoryDialog(subcategory: subcategory, categories: categories);
    } else if (setLogFilter == SettingsLogFilter.settings) {
      getSettingsAddEditSubcategoryDialog(subcategory: subcategory, categories: categories);
    } else if (setLogFilter == SettingsLogFilter.filter) {
      Env.store.dispatch(FilterSelectDeselectSubcategory(subcategory: subcategory));
    }
  }

  void _onItemReorder(int oldSubcategoryIndex, int oldCategoryIndex, int newSubcategoryIndex, int newCategoryIndex) {
    if (setLogFilter == SettingsLogFilter.log) {
      Env.store.dispatch(ReorderSubcategoryFromLogScreen(
          oldCategoryIndex: oldCategoryIndex,
          newCategoryIndex: newCategoryIndex,
          oldSubcategoryIndex: oldSubcategoryIndex,
          newSubcategoryIndex: newSubcategoryIndex));
    } else if (setLogFilter == SettingsLogFilter.settings) {
      Env.store.dispatch(ReorderSubcategoryFromSettingsScreen(
          oldCategoryIndex: oldCategoryIndex,
          newCategoryIndex: newCategoryIndex,
          oldSubcategoryIndex: oldSubcategoryIndex,
          newSubcategoryIndex: newSubcategoryIndex));
    }
  }

  void _onListReorder(int oldCategoryIndex, int newCategoryIndex) {
    if (setLogFilter == SettingsLogFilter.log) {
      Env.store.dispatch(
          ReorderCategoryFromLogScreen(oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex));
    } else if (setLogFilter == SettingsLogFilter.settings) {
      Env.store.dispatch(
          ReorderCategoryFromSettingsScreen(oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex));
    }
  }

  Widget _emptyContents({@required AppCategory category}) {
    String text = 'No subcategories please add one.';

    if (category.id == NO_CATEGORY) {
      text = '"No Category" doesn\'t have subcategories';
    } else if (category.id == TRANSFER_FUNDS) {
      text = '"Transfer funds" doesn\'t have subcategories';
    }

    return Text(
      text,
      style: TextStyle(
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
