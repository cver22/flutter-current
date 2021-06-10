import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';

import '../../app/common_widgets/list_tile_components.dart';
import '../../env.dart';
import '../../store/actions/filter_actions.dart';
import '../../store/actions/logs_actions.dart';
import '../../store/actions/settings_actions.dart';
import '../../utils/db_consts.dart';
import '../categories_model/app_category/app_category.dart';
import 'category_list_tile.dart';
import 'category_list_tools.dart';

class MasterCategoryDragAndDropList extends StatelessWidget {
  final List<String>? selectedCategories;
  final List<String>? selectedSubcategories;
  final List<AppCategory?> categories;
  final List<AppCategory?> subcategories;
  final SettingsLogFilterEntry setLogFilter;

  const MasterCategoryDragAndDropList(
      {Key? key,
      required this.categories,
      required this.subcategories,
      required this.setLogFilter,
      required this.selectedCategories,
      required this.selectedSubcategories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Build drag and drop');
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

  _buildList({required int outerIndex}) {
    List<bool> expandedCategories = [];
    expandedCategories = setExpandedCategories(expandedCategories);

    AppCategory category = categories[outerIndex]!;
    List<AppCategory> subs = List.from(subcategories);
    //retain subcategory list based on parent category list
    subs.retainWhere((subcategory) => subcategory.parentCategoryId == category.id);

    return DragAndDropListExpansion(
      canDrag: setLogFilter != SettingsLogFilterEntry.filter,
      initiallyExpanded: expandedCategories[outerIndex],
      onExpansionChanged: (bool) {
        _onExpansionChanged(outerIndex);
      },
      contentsWhenEmpty: _emptyContents(category: category),
      title: Text(category.name!),
      leading: CategoryListTileLeading(category: category),
      trailing: _setTrailingIcon(category: category, expandedCategories: expandedCategories, outerIndex: outerIndex),
      children: List.generate(
          subs.length,
          (index) => _buildItem(
              subcategory: subs[index],
              categories: categories,
              selected: selectedSubcategories != null ? selectedSubcategories!.contains(subs[index].id) : false)),
      listKey: ObjectKey(subs),
    );
  }

  Widget _setTrailingIcon(
      {required AppCategory category, required List<bool> expandedCategories, required int outerIndex}) {
    if (setLogFilter == SettingsLogFilterEntry.filter && selectedCategories != null) {
      return FilterListTileTrailing(
          onTap: () => Env.store.dispatch(FilterSelectDeselectCategory(id: category.id!)),
          selected: selectedCategories!.contains(category.id));
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
    if (setLogFilter == SettingsLogFilterEntry.log) {
      Env.store.dispatch(LogExpandCollapseCategory(index: outerIndex));
    } else if (setLogFilter == SettingsLogFilterEntry.settings) {
      Env.store.dispatch(SettingsExpandCollapseCategory(index: outerIndex));
    } else if (setLogFilter == SettingsLogFilterEntry.filter) {
      Env.store.dispatch(FilterExpandCollapseCategory(index: outerIndex));
    }
  }

  List<bool> setExpandedCategories(List<bool> expandedCategories) {
    if (setLogFilter == SettingsLogFilterEntry.log) {
      expandedCategories = List.from(Env.store.state.logsState.expandedCategories);
    } else if (setLogFilter == SettingsLogFilterEntry.settings) {
      expandedCategories = List.from(Env.store.state.settingsState.expandedCategories);
    } else if (setLogFilter == SettingsLogFilterEntry.filter) {
      expandedCategories = List.from(Env.store.state.filterState.expandedCategories);
    }
    return expandedCategories;
  }

  _buildItem({required AppCategory subcategory, required List<AppCategory?> categories, bool selected = false}) {
    return DragAndDropItem(
        canDrag: setLogFilter != SettingsLogFilterEntry.filter,
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

  void _onTapEdit(AppCategory subcategory, List<AppCategory?> categories) {
    if (setLogFilter == SettingsLogFilterEntry.log) {
      getLogAddEditSubcategoryDialog(subcategory: subcategory, categories: categories);
    } else if (setLogFilter == SettingsLogFilterEntry.settings) {
      getSettingsAddEditSubcategoryDialog(subcategory: subcategory, categories: categories);
    } else if (setLogFilter == SettingsLogFilterEntry.filter) {
      Env.store.dispatch(FilterSelectDeselectSubcategory(id: subcategory.id!));
    }
  }

  void _onItemReorder(int oldSubcategoryIndex, int oldCategoryIndex, int newSubcategoryIndex, int newCategoryIndex) {
    if (setLogFilter == SettingsLogFilterEntry.log) {
      Env.store.dispatch(LogReorderSubcategory(
          oldCategoryIndex: oldCategoryIndex,
          newCategoryIndex: newCategoryIndex,
          oldSubcategoryIndex: oldSubcategoryIndex,
          newSubcategoryIndex: newSubcategoryIndex));
    } else if (setLogFilter == SettingsLogFilterEntry.settings) {
      Env.store.dispatch(SettingsReorderSubcategory(
          oldCategoryIndex: oldCategoryIndex,
          newCategoryIndex: newCategoryIndex,
          oldSubcategoryIndex: oldSubcategoryIndex,
          newSubcategoryIndex: newSubcategoryIndex));
    }
  }

  void _onListReorder(int oldCategoryIndex, int newCategoryIndex) {
    if (setLogFilter == SettingsLogFilterEntry.log) {
      Env.store.dispatch(LogReorderCategory(oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex));
    } else if (setLogFilter == SettingsLogFilterEntry.settings) {
      Env.store
          .dispatch(SettingsReorderCategory(oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex));
    }
  }

  Widget _emptyContents({required AppCategory category}) {
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
