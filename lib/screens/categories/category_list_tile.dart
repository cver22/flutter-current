import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:flutter/material.dart';

class CategoryListTile extends StatelessWidget {
  final MyCategory category;
  final VoidCallback onTap;

  const CategoryListTile({Key key, @required this.category, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: category.iconData != null ? Icon(category.iconData): Container(),
      title: Text(category.name),
      onTap: onTap,
      //TODO add method to edit
    );
  }
}
