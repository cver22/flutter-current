import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../tags/tag_model/tag.dart';
import '../../utils/currency.dart';
import '../../utils/db_consts.dart';
import '../../utils/expense_routes.dart';

class EntriesListTile extends StatelessWidget {
  final AppEntry entry;
  final Map<String, Tag> tags;

  const EntriesListTile({Key key, @required this.entry, @required this.tags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Log log;
    DateTime date = entry.dateTime;

    if (entry?.logId != null) {
      log = Env.store.state.logsState.logs?.values?.firstWhere(
          (element) => element?.id == entry?.logId,
          orElse: () => null);
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
                  entry?.comment != null && entry.comment.length > 0
                      ? Text(entry.comment)
                      : Container(),
                ],
              ),
            ),
            trailing: _buildTrailingContents(date: date),
            onTap: () => {
              Env.store.dispatch(EntrySelectEntry(entryId: entry.id)),
              Get.toNamed(ExpenseRoutes.addEditEntries),
            },
            /* onLongPress: () => {
              //TODO multi select
            },*/
          ),
          Divider(height: 0.0),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildTrailingContents({@required DateTime date}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${formattedAmount(value: entry?.amount, withSeparator: true)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        SizedBox(height: 8.0),
        Text(
          '${MONTHS_SHORT[date.month - 1]} ${date.day.toString()}, ${date.year.toString()}',
          style: TextStyle(fontSize: 12.0),
        ),
      ],
    );
  }

  String displayChar({@required Log log}) {
    String emojiChar;
    String subcategoryId = entry?.subcategoryId;

    if (subcategoryId != null && !subcategoryId.contains(OTHER)) {
      emojiChar = log.subcategories
          .firstWhere((element) => element.id == subcategoryId,
              orElse: () => null)
          ?.emojiChar;
    }

    if (entry?.categoryId != null && emojiChar == null) {
      emojiChar = log.categories
              .firstWhere((element) => element.id == entry.categoryId,
                  orElse: () => null)
              ?.emojiChar ??
          '\u{2757}';
    }

    return emojiChar;
  }

  Widget categoriesSubcategories({@required Log log}) {
    AppCategory category = log?.categories?.firstWhere(
        (element) => element.id == entry?.categoryId,
        orElse: () => log?.categories
            ?.firstWhere((element) => element.id == NO_CATEGORY));
    AppCategory subcategory = log?.subcategories?.firstWhere(
        (element) => element.id == entry?.subcategoryId,
        orElse: () => null);

    bool hasSubcategory = subcategory != null;

    return Wrap(
      children: [
        hasSubcategory
            ? Text(
                '${subcategory.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              )
            : Container(),
        hasSubcategory
            ? Text(
                '${category.emojiChar} ${category.name}',
              )
            : Text(
                '${category.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ],
    );
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
