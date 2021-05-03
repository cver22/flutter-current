import 'package:collection/collection.dart' show IterableExtension;
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../categories/categories_model/app_category/app_category.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../tags/tag_model/tag.dart';
import '../../currency/currency_utils/currency_formatters.dart';
import '../../utils/db_consts.dart';
import '../../utils/expense_routes.dart';

class EntriesListTile extends StatelessWidget {
  final AppEntry entry;
  final Map<String, Tag> tags;

  const EntriesListTile({Key? key, required this.entry, required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Log? log;
    late DateTime date = entry.dateTime;

    if (entry.logId.length > 0) {
      log = Env.store.state!.logsState.logs.values
          .firstWhereOrNull((element) => element.id == entry.logId);
    }
    if (log != null) {
      Currency logCurrency = CurrencyService().findByCode(log.currency)!;
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
                  if (entry.tagIDs.length > 0) _buildTagWidget(logId: log.id),
                  if (entry.comment.length > 0) Text(entry.comment),
                ],
              ),
            ),
            trailing: _buildTrailingContents(date: date, logCurrency: logCurrency),
            onTap: () =>
            {
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

  Widget _buildTrailingContents({required DateTime date, required Currency logCurrency}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${formattedAmount(value: entry.amount, showSeparators: true, currency: logCurrency, showSymbol: true)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
        ),
        if(entry.currency != logCurrency.code)
          Text(
            '${formattedAmount(value: entry.amountForeign,
                showSeparators: true,
                currency: CurrencyService().findByCode(entry.currency)!,
                showSymbol: true,
                showCurrency: true)}',
            style: TextStyle(fontSize: 14.0),
          ),
        SizedBox(height: 4.0),
        Text(
          '${MONTHS_SHORT[date.month - 1]} ${date.day.toString()}, ${date.year.toString()}',
          style: TextStyle(fontSize: 12.0),
        ),
      ],
    );
  }

  String? displayChar({required Log log}) {
    String? emojiChar;
    String subcategoryId = entry.subcategoryId;

    if (!subcategoryId.contains(OTHER)) {
      emojiChar = log.subcategories
          .firstWhere((element) => element.id == subcategoryId)
          .emojiChar;
    }

    if (entry.categoryId != NO_CATEGORY && emojiChar == null) {
      emojiChar =
          log.categories
              .firstWhere((element) => element.id == entry.categoryId)
              .emojiChar;
    }

    return emojiChar;
  }

  Widget categoriesSubcategories({required Log log}) {
    AppCategory category = log.categories.firstWhere((element) => element.id == entry.categoryId,
        orElse: () => log.categories.firstWhere((element) => element.id == NO_CATEGORY));
    AppCategory subcategory =
    log.subcategories.firstWhere((element) => element.id == entry.subcategoryId);

    bool hasSubcategory = subcategory.id.length > 0;

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

  Widget _buildTagWidget({required String logId}) {
    String tagString = '';

    for (int i = 0; i < entry.tagIDs.length; i++) {
      Tag? tag = tags[entry.tagIDs[i]!];
      if (tag != null && tagString.isNotEmpty) {
        tagString += ', ';
      }

      if (tag != null) {
        tagString += '#${tag.name}';
      }
    }

    return tagString.isNotEmpty ? Text(tagString) : Container();
  }
}
