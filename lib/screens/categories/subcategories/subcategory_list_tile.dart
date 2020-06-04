import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:flutter/material.dart';

class SubcategoryListTile extends StatelessWidget {
  final MySubcategory subcategory;
  final VoidCallback onTap;

  const SubcategoryListTile({Key key, @required this.subcategory, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: subcategory.iconData != null ? Icon(subcategory.iconData): Container(),
      title: Text(subcategory.name),
      onTap: onTap,
      //TODO add method to edit
    );
  }
}
