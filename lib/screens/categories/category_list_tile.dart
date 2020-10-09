import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:flutter/material.dart';

class CategoryListTile extends StatelessWidget {
  final MyCategory category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryListTile({Key key, @required this.category, this.onTap, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: onLongPress,
      leading: category.iconData != null ? Icon(category.iconData): Icon(Icons.error),
      title: Text(category.name),
      //TODO trailing options
      onTap: onTap,
      //TODO add method to edit
    );
  }
}
