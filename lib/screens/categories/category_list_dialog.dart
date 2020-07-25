import 'package:expenses/env.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/screens/categories/category_list_tile.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/maybe.dart';

import 'package:flutter/material.dart';

class CategoryListDialog extends StatelessWidget {

  //TODO Start here, was not saving properly last time and now need to confirm that this pops up the categories dialog

  CategoryListDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyCategory> _categories = Env.store.state.logsState.logs[Env.store.state.entriesState.selectedEntry.value.logId].categories;
    return Container(
      margin: EdgeInsets.all(30.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: SimpleDialog(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[IconButton()],
              ),
              ReorderableListView(
                //TODO implement onReorder
                  children: _categories
                      .map((MyCategory category) => CategoryListTile(
                          category: category,
                          onTap: () {
                            Env.store.dispatch(UpdateSelectedEntry(category: category.id));
                            Env.store.dispatch(UpdateCategoriesStatus(subcategories: Maybe.some(
                              _log.subcategories
                                  .where((e) => e.parentCategoryId == category.id)
                                  .toList(),
                            )));
                            //TODO navigate to subcategories and set List<MySubcategory>
                          }))
                      .toList()),
            ],
          ),
        ],
      ),
    );
  }
}
