import 'dart:collection';

import '../../app/models/app_state.dart';
import '../../categories/categories_model/app_category/app_category.dart';
import '../../filter/filter_model/filter.dart';
import '../../filter/filter_model/filter_state.dart';
import '../../log/log_model/log.dart';
import 'app_actions.dart';
import '../../tags/tag_model/tag.dart';
import '../../utils/db_consts.dart';
import '../../utils/maybe.dart';
import 'package:collection/collection.dart' show IterableExtension;

AppState Function(AppState) _updateFilterAndFlagUpdated(FilterState? update(filterState)) {
  return (state) => state.copyWith(filterState: update(state.filterState.copyWith(updated: true)));
}

class FilterExpandCollapseCategory implements AppAction {
  final int index;

  FilterExpandCollapseCategory({required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.filterState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated((filterState) => filterState.copyWith(expandedCategories: expandedCategories)),
      ],
    );
  }
}

class FilterSetReset implements AppAction {
  final EntriesCharts? entriesChart;
  final Log? log;

  FilterSetReset({this.entriesChart, this.log});

  AppState updateState(AppState appState) {
    Filter updatedFilter = Filter.initial();
    List<Log?> logs = [];
    Map<String, AppCategory?> allCategories = LinkedHashMap();
    Map<String, AppCategory?> allSubcategories = LinkedHashMap();
    Map<String, AppCategory> consolidatedCategories = LinkedHashMap();
    Map<String, AppCategory?> consolidatedSubcategories = LinkedHashMap();
    List<bool> expandedCategories = [];
    Map<String?, String?> members = LinkedHashMap();
    List<Tag> allTags = [];
    List<String> selectedLogs = [];
    bool updated = false;

    if (log != null) {
      //action was triggered directly from a log and user wishes to filter for only that log
      logs.add(log);
      selectedLogs.add(log!.id!);
    } else {
      //action was triggered from generic location, include all logs
      logs = List.from(appState.logsState.logs.values.toList());
    }

    //creates lists the user can select from an overwrites the list every time because these elements are dynamic
    if (logs.isNotEmpty) {
      logs.forEach((log) {
        //create map of allMembers
        log!.logMembers.forEach((key, member) {
          if (!members.containsKey(key)) {
            members.putIfAbsent(key, () => member.name);
          }
        });

        //complete list of all categories
        log.categories.forEach((category) {
          allCategories.putIfAbsent(category.id!, () => category);
        });

        //complete list of all categories
        log.subcategories.forEach((subcategory) {
          allSubcategories.putIfAbsent(subcategory.id!, () => subcategory);
        });
      });
    }

    if (log == null) {
      //update all parentIds to parent name
      allSubcategories.updateAll((key, subcategory) {
        return subcategory!.copyWith(parentCategoryId: allCategories[subcategory.parentCategoryId]!.name);
      });

      allSubcategories.forEach((key, subcategory) {
        bool insert = true;
        consolidatedSubcategories.forEach((key, cSub) {
          //check if the subcategory is a duplicate for its category
          if (subcategory!.name == cSub!.name && subcategory.parentCategoryId == cSub.parentCategoryId && subcategory.id != NO_SUBCATEGORY) {
            insert = false;
          }
        });
        if (insert) {
          consolidatedSubcategories.putIfAbsent(subcategory!.id!, () => subcategory);
        }
      });

      allCategories.forEach((key, category) {
        bool insert = true;
        consolidatedCategories.forEach((key, cCat) {
          //check for name duplication
          if (category!.name == key) {
            insert = false;
          }
        });
        if (insert) {
          //add category to consolidated list and update id from name
          consolidatedCategories.putIfAbsent(category!.name!, () => category.copyWith(id: category.name));
        }
      });
    }

    allTags = _sortTags(
        allCategories: allCategories,
        filter: appState.filterState.filter,
        sortMethod: SortMethod.frequency,
        ascending: false,
        tags: Map.from(appState.tagState.tags),
        selectedLogs: selectedLogs);

    //create list of expanded categories the same size as the list of categories and set expanded to false
    consolidatedCategories.forEach((key, value) {
      expandedCategories.add(false);
    });

    //check if user is updating an existing filter
    if (entriesChart == EntriesCharts.entries && appState.entriesState.entriesFilter.isSome) {
      updatedFilter = appState.entriesState.entriesFilter.value;
      updated = true;
    } else if (entriesChart == EntriesCharts.charts && appState.entriesState.chartFilter.isSome) {
      updatedFilter = appState.entriesState.chartFilter.value;
      updated = true;
    } else if (log != null) {
      updatedFilter = updatedFilter.copyWith(selectedLogs: selectedLogs);
    }

    if (entriesChart != null) {
      //TODO remove any references to selected items that are no longer present
    }

    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) => filterState.copyWith(
              expandedCategories: expandedCategories,
              consolidatedCategories: consolidatedCategories.values.toList(),
              consolidatedSubcategories: consolidatedSubcategories.values.toList(),
              allMembers: members,
              filter: Maybe<Filter>.some(updatedFilter),
              updated: updated,
              allTags: allTags,
            )),
      ],
    );
  }
}

class FilterInitial implements AppAction {
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) => FilterState.initial()),
      ],
    );
  }
}

class FilterSelectDeselectCategory implements AppAction {
  final String id;

  FilterSelectDeselectCategory({required this.id});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> selectedCategories = List.from(filter.selectedCategories);
    List<String> selectedSubcategories = List.from(filter.selectedSubcategories);

    if (selectedCategories.contains(id)) {
      //deselection of a category deselects all subcategories
      selectedCategories.remove(id);
      appState.filterState.consolidatedSubcategories.forEach((subcategory) {
        if (subcategory.parentCategoryId == id) {
          selectedSubcategories.removeWhere((subCatId) => subCatId == subcategory.id);
        }
      });
    } else {
      //select category
      selectedCategories.add(id);
      appState.filterState.consolidatedSubcategories.forEach((subcategory) {
        if (subcategory.parentCategoryId == id) {
          selectedSubcategories.add(subcategory.id!);
        }
      });
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated((filterState) => filterState.copyWith(
                filter: Maybe<Filter>.some(filter.copyWith(
              selectedCategories: selectedCategories,
              selectedSubcategories: selectedSubcategories,
            )))),
      ],
    );
  }
}

class FilterSelectDeselectSubcategory implements AppAction {
  final String id;

  FilterSelectDeselectSubcategory({required this.id});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> selectedCategories = List.from(filter.selectedCategories);
    List<String> selectedSubcategories = List.from(filter.selectedSubcategories);
    AppCategory subcategory =
        appState.filterState.consolidatedSubcategories.firstWhere((subcategory) => subcategory.id == id);
    AppCategory category =
        appState.filterState.consolidatedCategories.firstWhere((element) => element.id == subcategory.parentCategoryId);

    if (selectedSubcategories.contains(id)) {
      //deselect subcategory
      selectedSubcategories.remove(id);

      //check if all subcategories have been unchecked, if so, uncheck the category
      bool categorySelected = false;
      appState.filterState.consolidatedSubcategories.forEach((cSub) {
        if (selectedSubcategories.contains(cSub.id)) {
          categorySelected = true;
        }
      });

      //no children subcategories are present to the parent category, remove the category
      if (!categorySelected && selectedCategories.contains(category.id)) {
        selectedCategories.remove(category.id);
      }

      //TODO if this is the last subcategory we are deselecting, then deselect the parent category
    } else {
      //select subcategory and its parent category if not already selected
      selectedSubcategories.add(id);
      if (!selectedCategories.contains(category.id)) {
        selectedCategories.add(category.id!);
      }
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated((filterState) => filterState.copyWith(
                filter: Maybe<Filter>.some(filter.copyWith(
              selectedCategories: selectedCategories,
              selectedSubcategories: selectedSubcategories,
            )))),
      ],
    );
  }
}

class FilterClearCategorySelection implements AppAction {
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated((filterState) => filterState.copyWith(
                filter: Maybe<Filter>.some(appState.filterState.filter.value.copyWith(
              selectedCategories: const [],
              selectedSubcategories: const [],
            )))),
      ],
    );
  }
}

class FilterSetStartDate implements AppAction {
  final DateTime? date;

  FilterSetStartDate({this.date});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    Maybe<DateTime?> previousDate = filter.startDate;
    Maybe<DateTime?> updatedDate = Maybe<DateTime>.none();

    if (filter.endDate.isNone || date!.isBefore(filter.endDate.value!)) {
      //either no end date is set or start date must be before end date
      updatedDate = Maybe<DateTime?>.some(date);
    } else if (previousDate.isSome) {
      //if a previous date exists, revert to it, otherwise, no date has been set
      updatedDate = previousDate;
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated(
            (filterState) => filterState.copyWith(filter: Maybe<Filter>.some(filter.copyWith(startDate: updatedDate)))),
      ],
    );
  }
}

class FilterSetEndDate implements AppAction {
  final DateTime? date;

  FilterSetEndDate({this.date});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    Maybe<DateTime?> previousDate = filter.endDate;
    Maybe<DateTime?> updatedDate = Maybe<DateTime>.none();

    if (filter.startDate.isNone || date!.isAfter(filter.startDate.value!)) {
      //either no start date is set or end date must be after start date
      updatedDate = Maybe<DateTime?>.some(date);
    } else if (previousDate.isSome) {
      //if a previous date exists, revert to it, otherwise, no date has been set
      updatedDate = previousDate;
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated(
            (filterState) => filterState.copyWith(filter: Maybe<Filter>.some(filter.copyWith(endDate: updatedDate)))),
      ],
    );
  }
}

class FilterUpdateMinAmount implements AppAction {
  final int? minAmount;

  FilterUpdateMinAmount({this.minAmount});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    Maybe<int?> min = filter.minAmount;

    if (minAmount != null) {
      if (minAmount == 0) {
        min = Maybe<int>.none();
      } else {
        min = Maybe<int?>.some(minAmount);
      }
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated((filterState) => filterState.copyWith(
                filter: Maybe<Filter>.some(filter.copyWith(
              minAmount: min,
            )))),
      ],
    );
  }
}

class FilterUpdateMaxAmount implements AppAction {
  final int? maxAmount;

  FilterUpdateMaxAmount({this.maxAmount});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    //Maybe<int> min = filter.minAmount;
    Maybe<int?> max = filter.maxAmount;

    if (maxAmount != null) {
      if (maxAmount == 0) {
        max = Maybe<int>.none();
      } else {
        max = Maybe<int?>.some(maxAmount);
      }
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated((filterState) => filterState.copyWith(
                filter: Maybe<Filter>.some(filter.copyWith(
              maxAmount: max,
            )))),
      ],
    );
  }
}

class FilterSelectPaid implements AppAction {
  final String id;

  FilterSelectPaid({required this.id});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> membersPaid = List.from(filter.membersPaid);

    if (membersPaid.contains(id)) {
      membersPaid.remove(id);
    } else {
      membersPaid.add(id);
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated(
            (filterState) => filterState.copyWith(filter: Maybe<Filter>.some(filter.copyWith(membersPaid: membersPaid)))),
      ],
    );
  }
}

class FilterClearPaidSelection implements AppAction {
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) => filterState.copyWith(
            filter: Maybe<Filter>.some(appState.filterState.filter.value.copyWith(membersPaid: const [])))),
      ],
    );
  }
}

class FilterSelectSpent implements AppAction {
  final String id;

  FilterSelectSpent({required this.id});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> membersSpent = List.from(filter.membersSpent);

    if (membersSpent.contains(id)) {
      membersSpent.remove(id);
    } else {
      membersSpent.add(id);
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated(
            (filterState) => filterState.copyWith(filter: Maybe<Filter>.some(filter.copyWith(membersSpent: membersSpent)))),
      ],
    );
  }
}

class FilterClearSpentSelection implements AppAction {
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) => filterState.copyWith(
            filter: Maybe<Filter>.some(appState.filterState.filter.value.copyWith(membersSpent: const [])))),
      ],
    );
  }
}

class FilterSelectLog implements AppAction {
  final String logId;

  FilterSelectLog({required this.logId});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> selectedLogs = List.from(filter.selectedLogs);

    if (selectedLogs.contains(logId)) {
      selectedLogs.remove(logId);
    } else {
      selectedLogs.add(logId);
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated(
            (filterState) => filterState.copyWith(filter: Maybe<Filter>.some(filter.copyWith(selectedLogs: selectedLogs)))),
      ],
    );
  }
}

class FilterClearLogSelection implements AppAction {
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) => filterState.copyWith(
            filter: Maybe<Filter>.some(appState.filterState.filter.value.copyWith(selectedLogs: const [])))),
      ],
    );
  }
}

class FilterSelectDeselectTag implements AppAction {
  final String? name;

  FilterSelectDeselectTag({required this.name});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String?> selectedTags = List.from(filter.selectedTags);

    //remove if tag present
    if (selectedTags.contains(name)) {
      selectedTags.remove(name);
    } else {
      //add if tag selected
      selectedTags.add(name);
    }

    return updateSubstates(
      appState,
      [
        _updateFilterAndFlagUpdated((filterState) => filterState.copyWith(
              filter: Maybe<Filter>.some(filter.copyWith(selectedTags: selectedTags)),
              search: Maybe<String>.none(), // clear search bar
            )),
      ],
    );
  }
}

class FilterSetSearchedTags implements AppAction {
  final String search;

  FilterSetSearchedTags({required this.search});

  @override
  AppState updateState(AppState appState) {
    List<Tag> tags = List.from(appState.filterState.allTags);
    List<Tag> searchedTags = [];
    Maybe<String> searchMaybe = search.length > 0 ? Maybe<String>.some(search) : Maybe<String>.none();
    List<String> selectedTagIds = List.from(appState.filterState.filter.value.selectedTags);

    searchedTags = buildSearchedTagsList(tags: tags, tagIds: selectedTagIds, search: search);

    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) => filterState.copyWith(
              searchedTags: searchedTags,
              search: searchMaybe,
            )),
      ],
    );
  }
}

class FilterClearTagSearch implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) => filterState.copyWith(
              searchedTags: const [],
              search: Maybe<String>.none(),
            )),
      ],
    );
  }
}
//TODO what is going on here????

class FilterClearTagSelection implements AppAction {
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateFilterState((filterState) =>
            filterState.copyWith(filter: Maybe<Filter>.some(appState.filterState.filter.value.copyWith(selectedTags: const [])))),
      ],
    );
  }
}

List<Tag> _sortTags({
  SortMethod sortMethod = SortMethod.frequency,
  bool ascending = false,
  required List<String> selectedLogs,
  required Map<String, Tag> tags,
  Maybe<Filter>? filter,
  Map<String, AppCategory?>? allCategories,
}) {
  List<Tag> orderTags = [];

  //removes tags from unselected logs
  if (selectedLogs.isNotEmpty) {
    tags.removeWhere((key, element) {
      bool remove = true;
      selectedLogs.forEach((logId) {
        if (element.logId == logId) {
          remove = false;
        }
      });

      return remove;
    });
  }

  //updates filter tags to reference category names
  tags.updateAll((key, tag) {
    Map<String, int> categoryFrequency = {};

    tag.tagCategoryFrequency.forEach((categoryId, frequency) {
      String? categoryName = allCategories![categoryId]?.name; //TODO this shouldn't need fixing after handling subcategories differently
      print(categoryName);
      categoryFrequency.putIfAbsent(categoryName!, () => frequency);
    });

    return tag.copyWith(tagCategoryFrequency: categoryFrequency);
  });

  //create list of all tags so it can be sorted as desired by the user
  tags.forEach((key, tag) {
    if ((orderTags.singleWhereOrNull((it) => it.name == tag.name)) != null) {
      //tag exists in the list, add to its frequency from another log
      Tag tagToUpdate = orderTags.firstWhere((element) => element.name == tag.name);
      orderTags[orderTags.indexOf(tagToUpdate)] =
          tagToUpdate.copyWith(tagLogFrequency: tagToUpdate.tagLogFrequency + tag.tagLogFrequency);
    } else {
      //tag does not exist in the list, add it
      orderTags.add(tag);
    }
  });

  if (sortMethod == SortMethod.alphabetical) {
    orderTags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  } else if (sortMethod == SortMethod.frequency) {
    orderTags.sort((a, b) => a.tagLogFrequency.compareTo(b.tagLogFrequency));
  }

  if (!ascending) {
    orderTags = orderTags.reversed.toList();
  }

  return orderTags;
}
