import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entries/entries_screen/entries_screen_build_list_view.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
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
                entries: _buildFilteredEntries(entries: List.from(entries), entriesFilter: entriesState.entriesFilter));
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
  Maybe<EntriesFilter> entriesFilter,
}) {
  //only processes filters if a filter is present
  if (entriesFilter.isSome) {
    //minimum entry date
    if (entriesFilter.value.startDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isBefore(entriesFilter.value.startDate.value));
    }
    //maximum entry date
    if (entriesFilter.value.endDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isAfter(entriesFilter.value.endDate.value));
    }
    //is the entry logId found in the list of logIds selected
    if (entriesFilter.value.logId.length > 0) {
      entries.removeWhere((entry) => !entriesFilter.value.logId.contains(entry.logId));
    }
    //TODO currency filter
    //is the entry categoryID found in the list of categories selected
    if (entriesFilter.value.selectedCategories.length > 0) {
      //entries.removeWhere((entry) => !entriesFilter.value.selectedCategories.contains(entry.categoryId));
    }
    //is the entry subcategoryId found in the list of subcategories selected
    if (entriesFilter.value.selectedSubcategories.length > 0) {
      //entries.removeWhere((entry) => !entriesFilter.value.selectedSubcategories.contains(entry.subcategoryId));
    }
    //is the entry amount less than the min amount
    if (entriesFilter.value.minAmount.isSome) {
      entries.removeWhere((entry) => entry.amount < entriesFilter.value.minAmount.value);
    }
    //is the entry amount more than the max amount
    if (entriesFilter.value.maxAmount.isSome) {
      entries.removeWhere((entry) => entry.amount > entriesFilter.value.maxAmount.value);
    }
    //does the entry contain one of the selected members
    //TODO entryMember filter
    //TODO tag filter

  }

  return entries;
}
