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

  FilterSetReset({this.entriesChart});

  AppState updateState(AppState appState) {
    Filter updatedFilter = Filter.initial();
    List<Log> logs = List.from(appState.logsState.logs.values.toList());
    List<AppCategory> allCategories = [];
    List<AppCategory> allSubcategories = [];
    List<bool> expandedCategories = [];
    Map<String, String> members = {};
    List<Tag> allTags = [];

    //creates lists the user can select from an overwrites the list every time because these elements are dynamic
    if (logs.length > 0) {
      logs.forEach((log) {
        //create map of allMembers
        log.logMembers.forEach((key, member) {
          if (!members.containsKey(key)) {
            members.putIfAbsent(key, () => member.name);
          }
        });
        //create allCategory list replacing the id with the name
        log.categories.forEach((category) {
          if ((allCategories.singleWhere((cat) => cat.name == category.name, orElse: () => null)) == null) {
            //list does not contain this category, add it and change its id to its name
            allCategories.add(category.copyWith(id: category.name));
          }
          //create allSubcategory list
          log.subcategories.forEach((subcategory) {
            if (category.id == subcategory.parentCategoryId &&
                (allSubcategories.singleWhere((e) => e.name == subcategory.name, orElse: () => null)) == null) {
              //adds the subcategory if allSubcategories does not currently contain it in the list and change the parent Id to the name of the parent
              allSubcategories.add(subcategory.copyWith(parentCategoryId: category.name));
            }
          });
        });
      });
    }

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
    allCategories.forEach((element) {
      expandedCategories.add(false);
    });

    //check if user is updating an existing filter
    if (entriesChart == EntriesCharts.entries && appState.entriesState.entriesFilter.isSome) {
      updatedFilter = appState.entriesState.entriesFilter.value;
    } else if (entriesChart == EntriesCharts.charts && appState.entriesState.chartFilter.isSome) {
      updatedFilter = appState.entriesState.chartFilter.value;
    }

    if (entriesChart != null) {
      //TODO remove any references to selected items that are no longer present
    }

    print(members);

    return _updateFilterState(
        appState,
        (filterState) => filterState.copyWith(
              expandedCategories: expandedCategories,
              allCategories: allCategories,
              allSubcategories: allSubcategories,
              allMembers: members,
              filter: Maybe.some(updatedFilter),
              updated: false,
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
    List<String> selectedCategoryNames = List.from(filter.selectedCategoryNames);
    List<String> selectedSubcategoryIds = List.from(filter.selectedSubcategoryIds);

    if (selectedCategoryNames.contains(id)) {
      //deselection of a category deselects all subcategories
      selectedCategoryNames.remove(id);
      appState.filterState.allSubcategories.forEach((subcategory) {
        if (subcategory.parentCategoryId == id) {
          selectedSubcategoryIds.removeWhere((id) => id == subcategory.id);
        }
      });
    } else {
      //select category
      selectedCategoryNames.add(id);
      appState.filterState.allSubcategories.forEach((subcategory) {
        if (subcategory.parentCategoryId == id) {
          selectedSubcategoryIds.add(subcategory.id);
        }
      });
    }

    return _updateFilter(
      appState: appState,
      filter: Maybe.some(filter.copyWith(
        selectedCategoryNames: selectedCategoryNames,
        selectedSubcategoryIds: selectedSubcategoryIds,
      )),
    );
  }
}

class FilterSelectDeselectSubcategory implements AppAction {
  final AppCategory subcategory;

  FilterSelectDeselectSubcategory({@required this.subcategory});

  AppState updateState(AppState appState) {
    Filter filter = appState.filterState.filter.value;
    List<String> selectedCategoryNames = List.from(filter.selectedCategoryNames);
    List<String> selectedSubcategoryIds = List.from(filter.selectedSubcategoryIds);

    if (selectedSubcategoryIds.contains(subcategory.id)) {
      //deselect subcategory
      selectedSubcategoryIds.remove(subcategory.id);
      //TODO if this is the last subcategory we are deselecting, then deselect the parent category
    } else {
      //select subcategory and its parent category if not already selected
      selectedSubcategoryIds.add(subcategory.id);
      if (!selectedCategoryNames.contains(subcategory.parentCategoryId)) {
        selectedCategoryNames.add(subcategory.parentCategoryId);
      }
    }

    return _updateFilter(
        appState: appState,
        filter: Maybe.some(filter.copyWith(
          selectedCategoryNames: selectedCategoryNames,
          selectedSubcategoryIds: selectedSubcategoryIds,
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
