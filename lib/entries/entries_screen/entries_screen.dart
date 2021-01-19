import 'package:expenses/app/common_widgets/empty_content.dart';
import 'package:expenses/app/common_widgets/error_widget.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entries/entries_screen/entries_screen_build_list_view.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/store/actions/actions.dart';
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
          Env.store.dispatch(ClearSingleEntryState());

          if (entriesState.isLoading == true) {
            return ModalLoadingIndicator(loadingMessage: 'Loading your entries...', activate: true);
          } else if (entriesState.isLoading == false && entriesState.entries.isNotEmpty) {
            entries = entriesState.entries.entries.map((e) => e.value).toList();

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
    if (entriesFilter.value?.startDate != null) {
      entries.removeWhere((entry) => entry.dateTime.isBefore(entriesFilter.value.startDate));
    }
    //maximum entry date
    if (entriesFilter.value?.endDate != null) {
      entries.removeWhere((entry) => entry.dateTime.isAfter(entriesFilter.value.endDate));
    }
    //is the entry logId found in the list of logIds selected
    if(entriesFilter.value.logId.length > 0){
      entries.removeWhere((entry) => !entriesFilter.value.logId.contains(entry.logId));
    }
    //TODO currency filter
    //is the entry categoryID found in the list of categories selected
    if(entriesFilter.value.categories.length > 0){
      entries.removeWhere((entry) => !entriesFilter.value.categories.contains(entry.categoryId));
    }
    //is the entry subcategoryId found in the list of subcategories selected
    if(entriesFilter.value.subcategories.length > 0){
      entries.removeWhere((entry) => !entriesFilter.value.subcategories.contains(entry.subcategoryId));
    }
    //is the entry amount less than the min amount
    if(entriesFilter.value.minAmount != null){
      entries.removeWhere((entry) => entry.amount < entriesFilter.value.minAmount);
    }
    //is the entry amount more than the max amount
    if(entriesFilter.value.maxAmount != null){
      entries.removeWhere((entry) => entry.amount > entriesFilter.value.maxAmount);
    }
    //does the entry contain one of the selected members
    //TODO entryMember filter
    //TODO tag filter

  }

  return entries;
}
