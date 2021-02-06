import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/utils/currency.dart';
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
      log = Env.store.state.logsState.logs?.values
          ?.firstWhere((element) => element?.id == entry?.logId, orElse: () => null);
    }
    if (log != null) {
      return ListTile(
        leading: Text(
          '${displayChar(log)}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: EMOJI_SIZE),
        ),
        title: entry?.comment != null ? Text(entry.comment) : Text(''),
        subtitle: Text(categoriesSubcategoriesTags(log)),
        trailing: Text('\$${formattedAmount(value: entry?.amount, withSeparator: true)}'),
        onTap: () => {
          Env.store.dispatch(SelectEntry(entryId: entry.id)),
          Get.toNamed(ExpenseRoutes.addEditEntries),
        },
      );
    } else {
      return Container();
    }
  }

  String displayChar(Log log) {
    String emojiChar;

    if (entry?.categoryId != null && log != null) {
      emojiChar =
          log.categories.firstWhere((element) => element.id == entry.categoryId, orElse: () => null)?.emojiChar ??
              '\u{2757}';
    }

    return emojiChar;
  }

  String categoriesSubcategoriesTags(Log log) {
    MyCategory category = log?.categories?.firstWhere((element) => element.id == entry?.categoryId, orElse: () => log?.categories?.firstWhere((element) => element.id == NO_CATEGORY));
    MyCategory subcategory = log?.subcategories?.firstWhere((element) => element.id == entry?.subcategoryId);
    String categoryText = 'Category';
    String subcategoryText = 'Subcategory';

    categoryText =
        '${category.emojiChar} ${category.name}';

    subcategoryText =
        '${subcategory.emojiChar} ${subcategory.name}';

    return '$categoryText, ${subcategoryText ?? ''}, tags';
  }
}
