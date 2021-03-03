import 'dart:collection';

import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/filter/filter_model/filter.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

AppState _updateFilterState(
  AppState appState,
  FilterState update(FilterState filterState),
) {
  return appState.copyWith(filterState: update(appState.filterState));
}

AppState _updateFilter({
  AppState appState,
  Maybe<Filter> filter,
}) {
  return _updateFilterState(
      appState,
      (filterState) => filterState.copyWith(
            filter: filter,
            updated: true,
          ));
}

class FilterExpandCollapseCategory implements AppAction {
  final int index;

  FilterExpandCollapseCategory({@required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.filterState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return _updateFilterState(
        appState,
        (filterState) => filterState.copyWith(
              expandedCategories: expandedCategories,
            ));
  }
}

class FilterSetReset implements AppAction {
  final EntriesCharts entriesChart;
  final Log log;

  FilterSetReset({this.entriesChart, this.log});

  AppState updateState(AppState appState) {
    Filter updatedFilter = Filter.initial();
    List<Log> logs = [];
    Map<String, AppCategory> allCategories = LinkedHashMap();
    Map<String, AppCategory> allSubcategories = LinkedHashMap();
    Map<String, AppCategory> consolidatedCategories = LinkedHashMap();
    Map<String, AppCategory> consolidatedSubcategories = LinkedHashMap();
    List<bool> expandedCategories = [];
    Map<String, String> members = LinkedHashMap();
    List<Tag> allTags = [];
    Maybe<Log> selectedLog = Maybe.none();
    List<String> selectedLogs = [];
    bool updated = false;

    if (log != null) {
      //action was triggered directly from a log and user wishes to filter for only that log
      logs.add(log);
      selectedLog = Maybe.some(log);
      selectedLogs.add(log.id);
    } else {
      //action was triggered from generic location, include all logs
      logs = List.from(appState.logsState.logs.values.toList());
    }

    //creates lists the user can select from an overwrites the list every time because these elements are dynamic
    if (logs.length > 0) {
      logs.forEach((log) {
        //create map of allMembers
        log.logMembers.forEach((key, member) {
          if (!members.containsKey(key)) {
            members.putIfAbsent(key, () => member.name);
          }
        });

        //complete list of all categories
        log.categories.forEach((category) {
          allCategories.putIfAbsent(category.id, () => category);
        });

        //complete list of all categories
        log.subcategories.forEach((subcategory) {
          allSubcategories.putIfAbsent(subcategory.id, () => subcategory);
        });
      });
    }

    if (log == null) {
      //update all parentIds to parent name
      allSubcategories.updateAll((key, subcategory) {
        return subcategory.copyWith(parentCategoryId: allCategories[subcategory.parentCategoryId].name);
      });

      allSubcategories.forEach((key, subcategory) {
        bool insert = true;
        consolidatedSubcategories.forEach((key, cSub) {
          //check if the subcategory is a duplicate for its category
          if (subcategory.name == cSub.name && subcategory.parentCategoryId == cSub.parentCategoryId) {
            insert = false;
          }
        });
        if (insert) {
          consolidatedSubcategories.putIfAbsent(subcategory.id, () => subcategory);
        }
      });

      allCategories.forEach((key, category) {
        bool insert = true;
        consolidatedCategories.forEach((key, cCat) {
          //check for name duplication
          if (category.name == key) {
            insert = false;
          }
        });
        if (insert) {
          //add category to consolidated list and update id from name
          consolidatedCategories.putIfAbsent(category.name, () => category.copyWith(id: category.name));
        }
      });
    }

    //TODO should be filtered by log if navigated to from log
    //create list of all tags so it can be sorted as desired by the user
    appState.tagState.tags.forEach((key, tag) {
      if ((allTags.singleWhere((it) => it.name == tag.name, orElse: () => null)) != null) {
        //tag exists in the list, add to its frequency from another log
        Tag tagToUpdate = allTags.firstWhere((element) => element.name == tag.name);
        allTags[allTags.indexOf(tagToUpdate)] =
            tagToUpdate.copyWith(tagLogFrequency: tagToUpdate.tagLogFrequency + tag.tagLogFrequency);
      } else {
        //tag does not exist in the list, add it
        allTags.add(tag);
      }
    });

    allTags = _sortTags(sortMethod: SortMethod.alphabetical, ascending: true, allTags: allTags);

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
    } else if (log != null){
      updatedFilter = updatedFilter.copyWith(selectedLogs: selectedLogs);
    }

    if (entriesChart != null) {
      //TODO remove any references to selected items that are no longer present
    }

    return _updateFilterState(
        appState,
        (filterState) => filterState.copyWith(
              expandedCategories: expandedCategories,
              consolidatedCategories: consolidatedCategories.values.toList(),
              consolidatedSubcategories: consolidatedSubcategories.values.toList(),
              allMembers: members,
              filter: Maybe.some(updatedFilter),
              updated: updated,
              selectedLog: selectedLog,
            ));
  }
}

class FilterInitial implements AppAction {
  AppState updateState(AppState appState) {
    return _updateFilterState(appState, (filterState) => FilterState.initial());
  }
}

class FilterSelectDeselectCategory implements AppAction {
  final String id;

  FilterSelectDeselectCategory({@required this.id});

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
          selectedSubcategories.add(subcategory.id);
        }
      });
    }

    return _updateFilter(
      appState: appState,
      filter: Maybe.some(filter.copyWith(
        selectedCategories: selectedCategories,
        selectedSubcategories: selectedSubcategories,
      )),
    );
  }
}

class FilterSelectDeselectSubcategory implements AppAction {
  final String id;

  FilterSelectDeselectSubcategory({@required this.id});

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
        selectedCategories.add(category.id);
      }
    }

    return _updateFilter(
        appState: appState,
        filter: Maybe.some(filter.copyWith(
          selectedCategories: selectedCategories,
          selectedSubcategories: selectedSubcategories,
        )));
  }
}

class FilterSetStartDate implements AppAction {
  final DateTime dateTime;

  FilterSetStartDate({this.dateTime});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    Maybe<DateTime> previousDate = filter.startDate;
    Maybe<DateTime> updatedDateTime = Maybe.some(dateTime);

    //check if there is an end date
    if (filter.endDate.isSome) {
      //if so, start date can not be after the end date
      if (updatedDateTime.value.isAfter(filter.endDate.value) && previousDate.isSome) {
        if (previousDate.isSome) {
          //update with previous acceptable start date
          updatedDateTime = Maybe.some(previousDate.value);
        } else {
          //user needs to enter a valid start date
          updatedDateTime = Maybe.none();
        }
        //TODO toast error message

      }
    }

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(startDate: updatedDateTime)));
  }
}

class FilterSetEndDate implements AppAction {
  final DateTime dateTime;

  FilterSetEndDate({this.dateTime});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    Maybe<DateTime> previousDate = filter.endDate;
    Maybe<DateTime> updatedDateTime = Maybe.some(dateTime);

    //check if there is an start date
    if (filter.startDate.isSome) {
      //if so, end date can not be before the end date
      if (updatedDateTime.value.isBefore(filter.startDate.value)) {
        if (previousDate.isSome) {
          //update with previous acceptable end date
          updatedDateTime = Maybe.some(previousDate.value);
        } else {
          //user needs to enter a valid end date
          updatedDateTime = Maybe.none();
        }
        //TODO toast error message
      }
    }

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(endDate: updatedDateTime)));
  }
}

class FilterUpdateMinAmount implements AppAction {
  final int minAmount;

  FilterUpdateMinAmount({this.minAmount});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    Maybe<int> min = filter.minAmount;
    //Maybe<int> max = filter.maxAmount;

    if (minAmount != null) {
      if (minAmount == 0) {
        min = Maybe.none();
      } else {
        min = Maybe.some(minAmount);
      }
    }

    return _updateFilter(
        appState: appState,
        filter: Maybe.some(filter.copyWith(
          minAmount: min,
        )));
  }
}

class FilterUpdateMaxAmount implements AppAction {
  final int maxAmount;

  FilterUpdateMaxAmount({this.maxAmount});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    //Maybe<int> min = filter.minAmount;
    Maybe<int> max = filter.maxAmount;

    if (maxAmount != null) {
      if (maxAmount == 0) {
        max = Maybe.none();
      } else {
        max = Maybe.some(maxAmount);
      }
    }

    return _updateFilter(
        appState: appState,
        filter: Maybe.some(filter.copyWith(
          maxAmount: max,
        )));
  }
}

class FilterSelectPaid implements AppAction {
  final String id;

  FilterSelectPaid({@required this.id});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> membersPaid = List.from(filter.membersPaid);

    if (membersPaid.contains(id)) {
      membersPaid.remove(id);
    } else {
      membersPaid.add(id);
    }

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(membersPaid: membersPaid)));
  }
}

class FilterClearPaidSelection implements AppAction {
  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(membersPaid: const [])));
  }
}

class FilterSelectSpent implements AppAction {
  final String id;

  FilterSelectSpent({@required this.id});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> membersSpent = List.from(filter.membersSpent);

    if (membersSpent.contains(id)) {
      membersSpent.remove(id);
    } else {
      membersSpent.add(id);
    }

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(membersSpent: membersSpent)));
  }
}

class FilterClearSpentSelection implements AppAction {
  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(membersSpent: const [])));
  }
}

class FilterSelectLog implements AppAction {
  final String logId;

  FilterSelectLog({@required this.logId});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> selectedLogs = List.from(filter.selectedLogs);

    if (selectedLogs.contains(logId)) {
      selectedLogs.remove(logId);
    } else {
      selectedLogs.add(logId);
    }

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(selectedLogs: selectedLogs)));
  }
}

class FilterClearLogSelection implements AppAction {
  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;

    return _updateFilter(appState: appState, filter: Maybe.some(filter.copyWith(selectedLogs: const [])));
  }
}

List<Tag> _sortTags({SortMethod sortMethod = SortMethod.alphabetical, List<Tag> allTags, bool ascending = true}) {
  List<Tag> orderTags = List.from(allTags);

  if (sortMethod == SortMethod.alphabetical) {
    orderTags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  } else if (sortMethod == SortMethod.frequency) {
    orderTags.sort((a, b) => a.tagLogFrequency..compareTo(b.tagLogFrequency));
  }

  if (!ascending) {
    orderTags = orderTags.reversed;
  }

  return orderTags;
}
