import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/categories/category_list_tile.dart';
import 'package:flutter/material.dart';

class CategoryListPage extends StatelessWidget {
  final Log log;
  final MyEntry entry;

  const CategoryListPage({Key key, this.log, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyCategory> _categories = log.categories;
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (BuildContext context, int index) {
        final MyCategory _category = _categories[index];
          return CategoryListTile(
            category: _category,
            onTap: () {},
          );

      },
    );
  }
}
