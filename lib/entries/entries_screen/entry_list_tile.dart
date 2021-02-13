import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/my_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntryListTile extends StatelessWidget {
  final MyEntry entry;
  final Map<String, Tag> tags;

  const EntryListTile({Key key, @required this.entry, @required this.tags}) : super(key: key);

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
    String emojiChar = '\u{2757}';
    String subcategoryId = entry?.subcategoryId;

    if (subcategoryId != null && log != null && !subcategoryId.contains(OTHER)) {
      emojiChar =
          log.subcategories.firstWhere((element) => element.id == subcategoryId, orElse: () => null)?.emojiChar ??
              emojiChar;
    } else if (entry?.categoryId != null && log != null) {
      emojiChar =
          log.categories.firstWhere((element) => element.id == entry.categoryId, orElse: () => null)?.emojiChar ??
              emojiChar;
    }

    return emojiChar;
  }

  String categoriesSubcategoriesTags(Log log) {
    MyCategory category = log?.categories?.firstWhere((element) => element.id == entry?.categoryId,
        orElse: () => log?.categories?.firstWhere((element) => element.id == NO_CATEGORY));
    MyCategory subcategory =
        log?.subcategories?.firstWhere((element) => element.id == entry?.subcategoryId, orElse: () => null);
    String tagString = _buildTagString(logId: log.id);
    String categoryText = '';
    String subcategoryText = '';

    categoryText = '${category.emojiChar} ${category.name}';

    if (subcategory != null) {
      subcategoryText = ', ${subcategory.emojiChar} ${subcategory.name}';
    }

    return '$categoryText$subcategoryText$tagString';
  }

  String _buildTagString({@required String logId}) {
    String tagString = '';
    if (entry.tagIDs.length > 0) {
      entry.tagIDs.forEach((tagId) {
        Tag tag = tags[tagId];

        if (tag != null) {
          tagString += ', #${tag.name}';
        }
      });
    }

    return tagString;
  }
}
