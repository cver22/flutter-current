import 'package:expenses/env.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntryListTile extends StatelessWidget {
  final MyEntry entry;

  const EntryListTile({Key key, @required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Log log;
    if (entry?.logId != null) {
      log = Env.store.state.logsState.logs.values.firstWhere((element) => element?.id == entry?.logId);
    }

    return ListTile(
      leading: Icon(displayIcon(log)),
      title: entry?.comment != null ? Text(entry.comment) : Text(''),
      subtitle: Text(categoriesSubcategoriesTags(log)),
      trailing: Text('\$ ${entry?.amount.toString()}'),
      onTap: () => {
        Env.store.dispatch(SelectEntry(entryId: entry.id)),
        Get.toNamed(ExpenseRoutes.addEditEntries),
      },
    );
  }

  IconData displayIcon(Log log) {
    IconData iconData = Icons.error;

    if (entry?.categoryId != null && log != null) {
      iconData = log.categories.firstWhere((element) => element.id == entry.categoryId).iconData ?? iconData;
    }

    return iconData;
  }

  String categoriesSubcategoriesTags(Log log) {
    String category = 'Category';
    String subcategory = 'Subcategory';

    if (entry?.categoryId != null && log != null) {
      category = log.categories.firstWhere((element) => element.id == entry?.categoryId)?.name;
    }

    if (entry?.subcategoryId != null && log != null) {
      subcategory = log.subcategories.firstWhere((element) => element.id == entry?.subcategoryId)?.name;
    }

    return '$category, $subcategory, tags';
  }
}
