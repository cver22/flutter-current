import 'package:expenses/app/common_widgets/list_tile_components.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:flutter/material.dart';

class CategoryListTile extends StatelessWidget {
  final AppCategory category;
  final VoidCallback onTap;
  final VoidCallback onTapEdit;
  final bool inset;
  final SettingsLogFilter setLogFilter;
  final bool selected;

  const CategoryListTile({Key key, @required this.category, this.onTap, this.onTapEdit, this.inset = false, this.selected, this.setLogFilter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO implement default category system
    //String name;
    /*if(category?.isDefault == true){
      name = '${category.name}' + ' (Default)';
    }else{
      name = category.name;
    }*/
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(8, 0, 16, 0),
      leading: CategoryListTileLeading(
        category: category,
        sublist: inset, //only a sublist if there is no ontap method
      ),
      title: Text(category.name),
      trailing: setLogFilter == SettingsLogFilter.filter ? FilterListTileTrailing(onSelect: onTapEdit, selected: selected) : CategoryListTileTrailing(onTapEdit: onTapEdit),
      onTap: onTap,
    );
  }
}
