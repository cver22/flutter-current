import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter.dart';
import 'package:expenses/entries_filter/entries_filter_model/entries_filter_state.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

AppState _updateEntriesFilterState(
  AppState appState,
  EntriesFilterState update(EntriesFilterState entriesFilterState),
) {
  return appState.copyWith(entriesFilterState: update(appState.entriesFilterState));
}

AppState _updateEntriesFilter({
  AppState appState,
  Maybe<EntriesFilter> entriesFilter,
}) {
  return _updateEntriesFilterState(
      appState, (entriesFilterState) => entriesFilterState.copyWith(entriesFilter: entriesFilter));
}

class FilterExpandCollapseCategory implements AppAction {
  final int index;

  FilterExpandCollapseCategory({@required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.entriesFilterState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return _updateEntriesFilterState(
        appState,
        (entriesFilterState) => entriesFilterState.copyWith(
              expandedCategories: expandedCategories,
            ));
  }
}

class FilterSetReset implements AppAction {
  final EntriesCharts entriesChart;

  FilterSetReset({this.entriesChart});

  AppState updateState(AppState appState) {
    EntriesFilter updatedEntriesFilter = EntriesFilter.initial();
    Map<String, bool> selectedCategories = {};
    Map<String, bool> selectedSubcategories = {};
    List<AppCategory> allCategories = [];
    List<AppCategory> allSubcategories = [];
    List<bool> expandedCategories = [];
    List<Log> logs = List.from(appState.logsState.logs.values.toList());

    //consolidates the list of categories to prevent duplication
    if (logs.length > 0) {
      logs.forEach((log) {
        log.categories.forEach((category) {
          if ((allCategories.singleWhere((cat) => cat.name == category.name, orElse: () => null)) == null) {
            //list does not contain this category, add it and change its Id to its name
            allCategories.add(category.copyWith(id: category.name));
          }
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
    allCategories.forEach((element) {
      //create list of expanded categories the same size as the list of categories and set expanded to false
      expandedCategories.add(false);
      //create list of selected categories since we're looping this list anyway
      selectedCategories.putIfAbsent(element.id, () => false);
    });

    //check if user is updating an existing filter
    if (entriesChart == EntriesCharts.entries && appState.entriesState.entriesFilter.isSome) {
      updatedEntriesFilter = appState.entriesState.entriesFilter.value;
    } else if (entriesChart == EntriesCharts.charts && appState.entriesState.chartFilter.isSome) {
      updatedEntriesFilter = appState.entriesState.chartFilter.value;
    } else {
      //only process this list and update the selected cat & sub if a filter was not passed to the action
      allSubcategories.forEach((subcategory) {
        selectedSubcategories.putIfAbsent(subcategory.id, () => false);
      });

      updatedEntriesFilter = updatedEntriesFilter.copyWith(
          selectedCategories: selectedCategories, selectedSubcategories: selectedSubcategories);
    }

    return _updateEntriesFilterState(
        appState,
        (entriesFilterState) => entriesFilterState.copyWith(
            expandedCategories: expandedCategories,
            entriesFilter: Maybe.some(updatedEntriesFilter.copyWith(
              allCategories: allCategories,
              allSubcategories: allSubcategories,
            ))));
  }
}

class FilterSelectDeselectCategory implements AppAction {
  final String id;

  FilterSelectDeselectCategory({@required this.id});

  AppState updateState(AppState appState) {
    EntriesFilter entriesFilter = appState.entriesFilterState.entriesFilter.value;
    Map<String, bool> selectedCategories = entriesFilter.selectedCategories;
    selectedCategories.update(id, (value) => !value);

    return _updateEntriesFilter(
        appState: appState,
        entriesFilter: Maybe.some(entriesFilter.copyWith(
          selectedCategories: selectedCategories,
        )));
  }
}

class FilterSelectDeselectSubcategory implements AppAction {
  final AppCategory subcategory;

  FilterSelectDeselectSubcategory({@required this.subcategory});

  AppState updateState(AppState appState) {
    EntriesFilter entriesFilter = appState.entriesFilterState.entriesFilter.value;
    Map<String, bool> selectedCategories = entriesFilter.selectedCategories;
    Map<String, bool> selectedSubcategories = entriesFilter.selectedSubcategories;
    selectedSubcategories.update(subcategory.id, (value) => !value);

    if (selectedSubcategories[subcategory.id]) {
      selectedCategories.update(subcategory.parentCategoryId, (value) => true);
    }

    return _updateEntriesFilter(
        appState: appState,
        entriesFilter: Maybe.some(entriesFilter.copyWith(
          selectedCategories: selectedCategories,
          selectedSubcategories: selectedSubcategories,
        )));
  }
}

class FilterSetStartDate implements AppAction {
  final DateTime dateTime;

  FilterSetStartDate({this.dateTime});

  AppState updateState(AppState appState) {
    EntriesFilter entriesFilter = appState.entriesFilterState.entriesFilter.value;
    Maybe<DateTime> previousDate = entriesFilter.startDate;
    Maybe<DateTime> updatedDateTime = Maybe.some(dateTime);

    //check if there is an end date
    if (entriesFilter.endDate.isSome) {
      //if so, start date can not be after the end date
      if (updatedDateTime.value.isAfter(entriesFilter.endDate.value) && previousDate.isSome) {
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

    return _updateEntriesFilter(
        appState: appState, entriesFilter: Maybe.some(entriesFilter.copyWith(startDate: updatedDateTime)));
  }
}

class FilterSetEndDate implements AppAction {
  final DateTime dateTime;

  FilterSetEndDate({this.dateTime});

  AppState updateState(AppState appState) {
    EntriesFilter entriesFilter = appState.entriesFilterState.entriesFilter.value;
    Maybe<DateTime> previousDate = entriesFilter.endDate;
    Maybe<DateTime> updatedDateTime = Maybe.some(dateTime);

    //check if there is an start date
    if (entriesFilter.startDate.isSome) {
      //if so, end date can not be before the end date
      if (updatedDateTime.value.isBefore(entriesFilter.startDate.value)) {
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

    return _updateEntriesFilter(
        appState: appState, entriesFilter: Maybe.some(entriesFilter.copyWith(endDate: updatedDateTime)));
  }
}

class FilterUpdateAmount implements AppAction {
  final int minAmount;
  final int maxAmount;

  FilterUpdateAmount({this.minAmount, this.maxAmount});

  AppState updateState(AppState appState) {
    EntriesFilter entriesFilter = appState.entriesFilterState.entriesFilter.value;
    Maybe<int> min = entriesFilter.minAmount;
    Maybe<int> max = entriesFilter.minAmount;

    if (minAmount != null) {
      min = Maybe.some(minAmount);
    }
    if (maxAmount != null) {
      max = Maybe.some(maxAmount);
    }

    return _updateEntriesFilter(
        appState: appState,
        entriesFilter: Maybe.some(appState.entriesFilterState.entriesFilter.value.copyWith(
          minAmount: min,
          maxAmount: max,
        )));
  }
}
