import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/categories/subcategories/subcategory_list_tile.dart';
import 'package:flutter/material.dart';

class SubcategoryListPage extends StatelessWidget {
  final Log log;
  final MyEntry entry;

  const SubcategoryListPage({Key key, this.log, this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MySubcategory> _subcategories = log.subcategories;
    return ListView.builder(
      itemCount: _subcategories.length,
      itemBuilder: (BuildContext context, int index) {
        //TODO may be able to iterate map.forEach instead
        final MySubcategory _subcategory = _subcategories[index];
        return SubcategoryListTile(
          subcategory: _subcategory,
          onTap: () {},
        );
      },
    );
  }
}
