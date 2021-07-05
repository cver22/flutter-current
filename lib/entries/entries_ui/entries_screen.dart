import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/empty_content.dart';
import '../../app/common_widgets/error_widget.dart';
import '../../app/common_widgets/loading_indicator.dart';
import '../../entry/entry_model/app_entry.dart';
import '../../env.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/expense_routes.dart';
import '../../utils/utils.dart';
import '../entries_model/entries_state.dart';
import 'entries_screen_build_list_view.dart';

class EntriesScreen extends StatelessWidget {
  EntriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<AppEntry> entries = [];
    bool activateFAB = Env.store.state.logsState.logs.isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: activateFAB ? null : Colors.grey,
        onPressed: activateFAB
            ? () {
                Env.store.dispatch(EntrySetNew(memberId: Env.store.state.authState.user.value.id));
                Get.toNamed(ExpenseRoutes.addEditEntries);
              }
            : null,
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
            entries = entriesState.entriesFilter.isSome
                ? entriesState.filteredEntries.entries.map((e) => e.value).toList()
                : entriesState.entries.entries.map((e) => e.value).toList();

            if (!entriesState.descending) {
              //resort ascending if selected
              entries.sort((a, b) => a.dateTime.compareTo(b.dateTime));
            } else {
              entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
            }

            return EntriesScreenBuildListView(
              entries: entries,
              selectedEntries: entriesState.selectedEntries,
            );
          } else if (entriesState.isLoading == false && entriesState.entries.isEmpty) {
            return Env.store.state.logsState.logs.isEmpty ? LogEmptyContent() : EntriesEmptyContent();
          } else {
            //TODO pass meaningful error message
            return ErrorContent();
          }
        },
      ),
    );
  }
}
/*
List<AppEntry> _buildFilteredEntries({
  required List<AppEntry> entries,
  required Maybe<Filter> entriesFilter,
}) {
  //only processes filters if a filter is present
  if (entriesFilter.isSome) {
    Filter filter = entriesFilter.value;
    //minimum entry date
    if (filter.startDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isBefore(filter.startDate.value!));
    }
    //maximum entry date
    if (filter.endDate.isSome) {
      entries.removeWhere((entry) => entry.dateTime.isAfter(filter.endDate.value!));
    }
    //is the entry logId found in the list of logIds selected
    if (filter.selectedLogs.isNotEmpty) {
      entries.removeWhere((entry) => !filter.selectedLogs.contains(entry.logId));
    }

    if (filter.selectedCurrencies.isNotEmpty) {
      entries.removeWhere((entry) => !filter.selectedCurrencies.contains(entry.currency));
    }

    if (filter.minAmount.isSome) {
      entries.removeWhere((entry) => entry.amount < filter.minAmount.value!);
    }
    //is the entry amount more than the max amount
    if (filter.maxAmount.isSome) {
      entries.removeWhere((entry) => entry.amount > filter.maxAmount.value!);
    }

    //is the entry subcategoryId found in the list of subcategories selected
    if (filter.selectedSubcategories.isNotEmpty) {
      Map<String, Log> logs = Env.store.state.logsState.logs;

      entries.removeWhere((entry) {
        List<AppCategory?> subcategories = logs[entry.logId]!.subcategories;

        AppCategory? subcategory;

        if (entry.subcategoryId != null) {
          subcategory = subcategories.firstWhere((subcategory) => subcategory!.id == entry.subcategoryId);
        }

        if (subcategory != null && filter.selectedSubcategories.contains(subcategory.id)) {
          //filter contains subcategory, show entry
          return false;
        } else {
          //filter does not contain subcategory, remove entry
          return true;
        }
      });
    }

    //is the entry categoryID found in the list of categories selected
    if (filter.selectedCategories.length > 0) {
      Map<String, Log> logs = Env.store.state.logsState.logs;

      entries.removeWhere((entry) {
        List<AppCategory?> categories = logs[entry.logId]!.categories;
        String categoryName = categories.firstWhere((category) => category!.id! == entry.categoryId)!.name!;

        if (filter.selectedCategories.contains(categoryName)) {
          //filter contains category, show entry
          return false;
        } else {
          //filter does not contain category, remove entry
          return true;
        }
      });
    }

    //filter entries by who spent
    if (filter.membersPaid.length > 0) {
      entries.retainWhere((entry) {
        List<String> uids = [];
        bool retain = false;
        entry.entryMembers.values.forEach((entryMember) {
          if (entryMember.paying) {
            uids.add(entryMember.uid);
          }
        });

        filter.membersPaid.forEach((element) {
          if (uids.contains(element)) {
            retain = true;
          }
        });

        return retain;
      });
    }

    //filter entries by who paid
    if (filter.membersSpent.length > 0) {
      entries.retainWhere((entry) {
        List<String> uids = [];
        bool retain = false;
        entry.entryMembers.values.forEach((entryMember) {
          if (entryMember.spending) {
            uids.add(entryMember.uid);
          }
        });

        filter.membersSpent.forEach((element) {
          if (uids.contains(element)) {
            retain = true;
          }
        });

        return retain;
      });
    }

    //is the entry categoryID found in the list of categories selected
    if (filter.selectedTags.isNotEmpty) {
      entries.retainWhere((entry) {
        Map<String, Tag> allTags = Env.store.state.tagState.tags;
        List<String> entryTagIds = entry.tagIDs;
        List<String> entryTagNames = [];
        bool retain = false;

        if (entryTagIds.isNotEmpty) {
          //get name of all tags in the entry
          entryTagIds.forEach((id) {
            //error checking for improperly deleted tags
            if (allTags.keys.contains(id)) {
              entryTagNames.add(allTags[id]!.name);
            }
          });

          for (int i = 0; i < entryTagNames.length; i++) {
            if (filter.selectedTags.contains(entryTagNames[i])) {
              //entry contains at least one instance of a filtered tag
              retain = true;
              break;
            }
          }
        }

        return retain;
      });
    }
  }

  return entries;
}*/
