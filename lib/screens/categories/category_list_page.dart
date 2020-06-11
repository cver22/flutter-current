import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/categories/category_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryListPage extends StatelessWidget {
  final Log _log;
  final MyEntry _entry;

  const CategoryListPage({Key key, Log log, MyEntry entry})
      : _log = log,
        _entry = entry,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyCategory> _categories = _log.categories;
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
                  children: _categories
                      .map((MyCategory category) => CategoryListTile(
                          category: category,
                          onTap: () {
                            _entry.copyWith(category: category.id);
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
