import 'package:flutter/material.dart';

import '../../app/common_widgets/list_tile_components.dart';
import '../../utils/db_consts.dart';
import '../categories_model/app_category/app_category.dart';

class CategoryListTile extends StatelessWidget {
  final AppCategory category;
  final VoidCallback? onTap;
  final VoidCallback onTapEdit;
  final bool inset;
  final SettingsLogFilterEntry setLogFilter;
  final bool selected;

  const CategoryListTile(
      {Key? key,
      required this.category,
      this.onTap,
      required this.onTapEdit,
      this.inset = false,
      this.selected = false,
      required this.setLogFilter})
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
      title: Text(category.name!),
      trailing: setLogFilter == SettingsLogFilterEntry.filter
          ? FilterListTileTrailing(onTap: onTapEdit, selected: selected)
          : CategoryListTileTrailing(onTapEdit: onTapEdit),
      onTap: onTap,
    );
  }
}
