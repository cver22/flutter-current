import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EntriesListTile extends StatelessWidget {
  final MyEntry entry;
  final Map<String, Tag> tags;

  const EntriesListTile({Key key, @required this.entry, @required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Log log;

    if (entry?.logId != null) {
      log = Env.store.state.logsState.logs?.values
          ?.firstWhere((element) => element?.id == entry?.logId, orElse: () => null);
    }
    if (log != null) {
      return Column(
        children: [
          ListTile(
            leading: Text(
              '${displayChar(log: log)}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: EMOJI_SIZE),
            ),
            title: Transform.translate(
              offset: Offset(-16, 0),
              child: categoriesSubcategories(log: log),
            ),
            subtitle: Transform.translate(
              offset: Offset(-16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTagWidget(logId: log.id),
                  entry?.comment != null && entry.comment.length > 0 ? Text(entry.comment) : Container(),
                ],
              ),
            ),
            trailing: Text('\$${formattedAmount(value: entry?.amount, withSeparator: true)}'),
            onTap: () => {
              Env.store.dispatch(SelectEntry(entryId: entry.id)),
              Get.toNamed(ExpenseRoutes.addEditEntries),
            },
          ),
          Divider(height: 0.0),
        ],
      );
    } else {
      return Container();
    }
  }

  String displayChar({@required Log log}) {
    String emojiChar;
    String subcategoryId = entry?.subcategoryId;

    if (subcategoryId != null && !subcategoryId.contains(OTHER)) {
      emojiChar = log.subcategories.firstWhere((element) => element.id == subcategoryId, orElse: () => null)?.emojiChar;
    }

    if (entry?.categoryId != null && emojiChar == null) {
      emojiChar =
          log.categories.firstWhere((element) => element.id == entry.categoryId, orElse: () => null)?.emojiChar ??
              '\u{2757}';
    }

    return emojiChar;
  }

  Text categoriesSubcategories({@required Log log}) {
    AppCategory category = log?.categories?.firstWhere((element) => element.id == entry?.categoryId,
        orElse: () => log?.categories?.firstWhere((element) => element.id == NO_CATEGORY));
    AppCategory subcategory =
        log?.subcategories?.firstWhere((element) => element.id == entry?.subcategoryId, orElse: () => null);
    String categoryText = '';
    String subcategoryText = '';

    categoryText = '${category.name}';
    if (subcategory?.emojiChar != null) {
      categoryText = '${category.emojiChar} $categoryText';
    }

    if (subcategory != null) {
      subcategoryText = '${subcategory.name}, ';
    }

    return Text('$subcategoryText$categoryText');
  }

  Widget _buildTagWidget({@required String logId}) {
    String tagString = '';

    if (entry.tagIDs.length > 0) {
      for (int i = 0; i < entry.tagIDs.length; i++) {
        Tag tag = tags[entry.tagIDs[i]];
        if (tag != null) {
          tagString += '#${tag.name}';

          if (i < entry.tagIDs.length - 1) {
            tagString += ', ';
          }
        }
      }

      return Text(tagString);
    }

    return Container();
  }
}
