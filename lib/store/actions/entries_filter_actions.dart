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

class ExpandCollapseFilterCategory implements AppAction {
  final int index;

  ExpandCollapseFilterCategory({@required this.index});

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

class SetResetEntriesFilter implements AppAction {
  final EntriesCharts entriesChart;

  SetResetEntriesFilter({this.entriesChart});

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
          if ((allCategories.singleWhere((e) => e.name == category.name, orElse: () => null)) == null) {
            //list does not contain this category, add it and change its Id to its name
            allCategories.add(category.copyWith(parentCategoryId: category.name));
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
      allSubcategories.forEach((element) {
        selectedSubcategories.putIfAbsent(element.id, () => false);
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

class SelectDeselectFilterCategory implements AppAction {
  final String id;

  SelectDeselectFilterCategory({@required this.id});

  AppState updateState(AppState appState) {
    EntriesFilter entriesFilter = appState.entriesFilterState.entriesFilter.value;
    Map<String, bool> selectedCategories = entriesFilter.selectedCategories;
    selectedCategories.update(id, (value) => !value);

    return _updateEntriesFilterState(
        appState,
        (entriesFilterState) => entriesFilterState.copyWith(
                entriesFilter: Maybe.some(entriesFilter.copyWith(
              selectedCategories: selectedCategories,
            ))));
  }
}

class SelectDeselectFilterSubcategory implements AppAction {
  final AppCategory subcategory;

  SelectDeselectFilterSubcategory({@required this.subcategory});

  AppState updateState(AppState appState) {
    EntriesFilter entriesFilter = appState.entriesFilterState.entriesFilter.value;
    Map<String, bool> selectedCategories = entriesFilter.selectedCategories;
    Map<String, bool> selectedSubcategories = entriesFilter.selectedSubcategories;
    selectedSubcategories.update(subcategory.id, (value) => !value);

    if (selectedSubcategories[subcategory.id]) {
      selectedCategories.update(subcategory.parentCategoryId, (value) => true);
    }

    return _updateEntriesFilterState(
        appState,
        (entriesFilterState) => entriesFilterState.copyWith(
                entriesFilter: Maybe.some(entriesFilter.copyWith(
              selectedCategories: selectedCategories,
              selectedSubcategories: selectedSubcategories,
            ))));
  }
}
