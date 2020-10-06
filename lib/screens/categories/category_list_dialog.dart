import 'package:expenses/env.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/categories/category_list_tile.dart';
import 'package:expenses/screens/categories/subcategories/subcategory_list_dialog.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:flutter/material.dart';

class CategoryListDialog extends StatelessWidget {
  CategoryListDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Log _log = Env.store.state.logsState.logs[Env.store.state.entriesState.selectedEntry.value.logId];
    List<MyCategory> _categories = _log.categories;

    return Dialog(
      elevation: 5.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      //TODO move to constant
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Category',
                style: TextStyle(fontSize: 20.0),
              ),
            ],
          ),
          ListView(
              shrinkWrap: true,
              //TODO implement onReorder
              children: _categories
                  .map((MyCategory category) => CategoryListTile(
                      category: category,
                      onTap: () {
                        Env.store.dispatch(ChangeEntryCategories(category: category.id));

                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (_) => SubcategoryListDialog(
                            backChevron: () => {
                              Navigator.of(context).pop(),
                              showDialog(
                                context: context,
                                builder: (_) => CategoryListDialog(),
                              ),
                            },
                          ),
                        );
                      }))
                  .toList()),
        ],
      ),
    );
  }
}
