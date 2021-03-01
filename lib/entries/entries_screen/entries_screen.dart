import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entries/entries_screen/entries_screen_build_list_view.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/expense_routes.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../env.dart';

class EntriesScreen extends StatelessWidget {
  EntriesScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<MyEntry> entries = [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Env.store.dispatch(SetNewSelectedEntry());
          Get.toNamed(ExpenseRoutes.addEditEntries);
        },
        child: Icon(Icons.add),
      ),
      body: ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (entriesState) {
          print('Rendering entries screen');

          if (entriesState.isLoading == true) {
            return ModalLoadingIndicator(loadingMessage: 'Loading your entries...', activate: true);
          } else if (entriesState.isLoading == false && entriesState.entries.isNotEmpty) {
            entries = entriesState.entries.entries.map((e) => e.value).toList();

            if (entriesState.descending) {
              entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
            } else {
              entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
            }

            return EntriesScreenBuildListView(
                entries: _buildFilteredEntries(entries: List.from(entries), filter: entriesState.entriesFilter));
          } else if (entriesState.isLoading == false && entriesState.entries.isEmpty) {
            return EmptyContent();
          } else {
            //TODO pass meaningful error message
            return ErrorContent();
          }
        },
      ),
    );
  }
}

List<MyEntry> _buildFilteredEntries({
  List<MyEntry> entries,
  Maybe<Filter> filter,
}) {
  //only processes filters if a filter is present
  if (filter.isSome) {
    //minimum entry date
    if (filter.value.startDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isBefore(filter.value.startDate.value));
    }
    //maximum entry date
    if (filter.value.endDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isAfter(filter.value.endDate.value));
    }
    //is the entry logId found in the list of logIds selected
    if (filter.value.logId.length > 0) {
      entries.removeWhere((entry) => !filter.value.logId.contains(entry.logId));
    }
    //TODO currency filter
    //is the entry categoryID found in the list of categories selected
    if (filter.value.selectedCategoryNames.length > 0) {
      Map<String, Log> logs = Env.store.state.logsState.logs;

      entries.removeWhere((entry) {
        List<AppCategory> categories = logs[entry.logId].categories;
        String categoryName = categories.firstWhere((category) => category.id == entry.categoryId).name;

        if (filter.value.selectedCategoryNames.contains(categoryName)) {
          //filter contains category, show entry
          return false;
        } else {
          //filter does not contain category, remove entry
          return true;
        }
      });
    }
    //is the entry subcategoryId found in the list of subcategories selected
    if (filter.value.selectedSubcategoryIds.length > 0) {
      Map<String, Log> logs = Env.store.state.logsState.logs;

      entries.removeWhere((entry) {
        List<AppCategory> subcategories = logs[entry.logId].subcategories;

        AppCategory subcategory = subcategories.firstWhere((subcategory) => subcategory.id == entry.subcategoryId, orElse: () => null);

        if (subcategory != null && filter.value.selectedSubcategoryIds.contains(subcategory.id)) {
          //filter contains subcategory, show entry
          return false;
        } else {
          //filter does not contain subcategory, remove entry
          return true;
        }
      });
    }
    //is the entry amount less than the min amount
    if (filter.value.minAmount.isSome) {
      entries.removeWhere((entry) => entry.amount < filter.value.minAmount.value);
    }
    //is the entry amount more than the max amount
    if (filter.value.maxAmount.isSome) {
      entries.removeWhere((entry) => entry.amount > filter.value.maxAmount.value);
    }
    //does the entry contain one of the selected members
    //TODO entryMember filter
    //TODO tag filter

  }

  return entries;
}
