import 'package:collection/collection.dart' show IterableExtension;
import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/app/common_widgets/list_tile_components.dart';
import 'package:expenses/store/actions/entries_actions.dart';
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
  final List<String> selectedEntries;

  const EntriesListTile({Key? key, required this.entry, required this.tags, required this.selectedEntries})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Log? log;
    late DateTime date = entry.dateTime;
    bool selected = selectedEntries.contains(entry.id);

    log = Env.store.state.logsState.logs.values.firstWhereOrNull((element) => element.id == entry.logId);

    if (log != null) {
      Currency logCurrency = CurrencyService().findByCode(log.currency!)!;
      return Column(
        children: [
          Material(
            color: selected ? Colors.red[300] : ThemeData.light().canvasColor,
            child: InkWell(
              onLongPress: () {
                Env.store.dispatch(EntriesSelectEntry(entryId: entry.id));
              },
              onTap: () {
                if (selectedEntries.isNotEmpty) {
                  Env.store.dispatch(EntriesSelectEntry(entryId: entry.id));
                } else {
                  Env.store.dispatch(EntrySelectEntry(entryId: entry.id));
                  Get.toNamed(ExpenseRoutes.addEditEntries);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          Text(
                            '${displayChar(log: log)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: EMOJI_SIZE),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                categoriesSubcategories(log: log),
                                if (entry.tagIDs.isNotEmpty) _buildTagWidget(logId: log.id!),
                                if (entry.comment != null) Text(entry.comment!),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildTrailingContents(date: date, logCurrency: logCurrency),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AppDivider(),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildTrailingContents({required DateTime date, required Currency logCurrency}) {
    String settingCurrency = Env.store.state.settingsState.settings.value.homeCurrency;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${formattedAmount(
              value: entry.amount,
              showSeparators: true,
              currency: logCurrency,
              showSymbol: true,
              showCode: logCurrency.code != settingCurrency,
              showFlag: logCurrency.code != settingCurrency,
            )}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          if (entry.currency != logCurrency.code)
            Text(
              '${formattedAmount(
                value: entry.amountForeign ?? 0,
                showSeparators: true,
                currency: CurrencyService().findByCode(entry.currency)!,
                showSymbol: true,
                showCode: true,
                showFlag: true,
              )}',
              style: TextStyle(fontSize: 14.0),
            ),
          SizedBox(height: 4.0),
          Text(
            '${MONTHS_SHORT[date.month - 1]} ${date.day.toString()}, ${date.year.toString()}',
            style: TextStyle(fontSize: 12.0),
          ),
        ],
      ),
    );
  }

  String? displayChar({required Log log}) {
    String? emojiChar;
    String? subcategoryId = entry.subcategoryId;

    if (subcategoryId != null && !subcategoryId.contains(OTHER) && subcategoryId != NO_SUBCATEGORY) {
      emojiChar = log.subcategories.firstWhere((element) => element.id == subcategoryId).emojiChar;
    } else if (entry.categoryId != null) {
      emojiChar = log.categories.firstWhere((element) => element.id == entry.categoryId).emojiChar;
    } else {
      emojiChar = "🔴";
    }

    return emojiChar;
  }

  Widget categoriesSubcategories({required Log log}) {
    AppCategory category = log.categories.firstWhere((element) => element.id == entry.categoryId,
        orElse: () => log.categories.firstWhere((element) => element.id == NO_CATEGORY));
    AppCategory? subcategory;
    bool hasSubcategory = false;
    if (entry.subcategoryId != null && entry.subcategoryId != NO_SUBCATEGORY) {
      subcategory = log.subcategories.firstWhere((element) => element.id == entry.subcategoryId);
      hasSubcategory = true;
    }

    return Wrap(
      children: [
        hasSubcategory
            ? Text(
                '${subcategory!.name}',
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
      Tag? tag = tags[entry.tagIDs[i]];
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
