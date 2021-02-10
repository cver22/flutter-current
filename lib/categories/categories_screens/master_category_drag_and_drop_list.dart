import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:expenses/categories/categories_screens/category_list_tile_components.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_screens/category_list_tile.dart';
import 'package:expenses/categories/categories_screens/category_list_tools.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

import '../../env.dart';

class MasterCategoryDragAndDropList extends StatelessWidget {
  final List<MyCategory> categories;
  final List<MyCategory> subcategories;
  final SettingsLogEntry setLogEnt;

  const MasterCategoryDragAndDropList(
      {Key key, @required this.categories, @required this.subcategories, @required this.setLogEnt})
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
    if (setLogEnt == SettingsLogEntry.log) {
      expandedCategories = List.from(Env.store.state.logsState.expandedCategories);
    } else if (setLogEnt == SettingsLogEntry.settings) {
      expandedCategories = List.from(Env.store.state.settingsState.expandedCategories);
    }

    MyCategory category = categories[outerIndex];
    List<MyCategory> subs = List.from(subcategories);
    subs.retainWhere((subcategory) => subcategory.parentCategoryId == category.id);
    return DragAndDropListExpansion(
      initiallyExpanded: expandedCategories[outerIndex],
      onExpansionChanged: (bool) {
        if (setLogEnt == SettingsLogEntry.log) {
          Env.store.dispatch(ExpandCollapseLogCategory(index: outerIndex));
        } else if (setLogEnt == SettingsLogEntry.settings) {
          Env.store.dispatch(ExpandCollapseSettingsCategory(index: outerIndex));
        }
      },
      contentsWhenEmpty: _emptyContents(category: category),
      title: Text(category.name),
      leading: CategoryListTileLeading(category: category),
      trailing: MasterCategoryListTileTrailing(
        categories: categories,
        category: category,
        expanded: expandedCategories[outerIndex],
        setLogEnt: setLogEnt,
      ),
      children: List.generate(subs.length, (index) => _buildItem(subcategory: subs[index], categories: categories)),
      listKey: ObjectKey(subs),
    );
  }

  _buildItem({@required MyCategory subcategory, @required List<MyCategory> categories}) {
    return DragAndDropItem(
        child: CategoryListTile(
          inset: true,
      onTapEdit: () {
        if (setLogEnt == SettingsLogEntry.log) {
          getLogAddEditSubcategoryDialog(subcategory: subcategory, categories: categories);
        } else if (setLogEnt == SettingsLogEntry.settings) {
          getSettingsAddEditSubcategoryDialog(subcategory: subcategory, categories: categories);
        }
      },
      category: subcategory,
    ));
  }

  void _onItemReorder(int oldSubcategoryIndex, int oldCategoryIndex, int newSubcategoryIndex, int newCategoryIndex) {
    if (setLogEnt == SettingsLogEntry.log) {
      Env.store.dispatch(ReorderSubcategoryFromLogScreen(
          oldCategoryIndex: oldCategoryIndex,
          newCategoryIndex: newCategoryIndex,
          oldSubcategoryIndex: oldSubcategoryIndex,
          newSubcategoryIndex: newSubcategoryIndex));
    } else if (setLogEnt == SettingsLogEntry.settings) {
      Env.store.dispatch(ReorderSubcategoryFromSettingsScreen(
          oldCategoryIndex: oldCategoryIndex,
          newCategoryIndex: newCategoryIndex,
          oldSubcategoryIndex: oldSubcategoryIndex,
          newSubcategoryIndex: newSubcategoryIndex));
    }
  }

  void _onListReorder(int oldCategoryIndex, int newCategoryIndex) {
    if (setLogEnt == SettingsLogEntry.log) {
      Env.store.dispatch(
          ReorderCategoryFromLogScreen(oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex));
    } else if (setLogEnt == SettingsLogEntry.settings) {
      Env.store.dispatch(
          ReorderCategoryFromSettingsScreen(oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex));
    }
  }

  Widget _emptyContents({@required MyCategory category}) {
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
