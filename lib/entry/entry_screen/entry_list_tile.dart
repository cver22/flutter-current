import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/db_consts.dart';
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
      leading: Text(
        '${displayChar(log)}',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: EMOJI_SIZE),
      ),
      title: entry?.comment != null ? Text(entry.comment) : Text(''),
      subtitle: Text(categoriesSubcategoriesTags(log)),
      trailing: Text('\$ ${entry?.amount?.toStringAsFixed(2)}'),
      onTap: () => {
        Env.store.dispatch(ClearSelectedEntry()),
        Env.store.dispatch(SelectEntry(entryId: entry.id)),
        Get.toNamed(ExpenseRoutes.addEditEntries),
      },
    );
  }

  String displayChar(Log log) {
    String emojiChar;

    if (entry?.categoryId != null && log != null) {
      emojiChar = log.categories.firstWhere((element) => element.id == entry.categoryId)?.emojiChar ?? '\u{2757}';
    }

    return emojiChar;
  }

  String categoriesSubcategoriesTags(Log log) {
    String category = 'Category';
    String subcategory = 'Subcategory';

    if (entry?.categoryId != null && log != null) {
      category =
          '${log.categories.firstWhere((element) => element.id == entry?.categoryId)?.emojiChar} ${log.categories.firstWhere((element) => element.id == entry?.categoryId)?.name}';
    }

    if (entry?.subcategoryId != null && log != null) {
      subcategory =
          '${log.subcategories.firstWhere((element) => element.id == entry?.subcategoryId)?.emojiChar} ${log.subcategories.firstWhere((element) => element.id == entry?.subcategoryId)?.name}';
    }

    return '$category, $subcategory, tags';
  }
}
