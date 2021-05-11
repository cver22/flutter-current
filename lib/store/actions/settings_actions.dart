import 'package:uuid/uuid.dart';

import '../../app/models/app_state.dart';
import '../../categories/categories_model/app_category/app_category.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../settings/settings_model/settings.dart';
import '../../utils/maybe.dart';
import 'app_actions.dart';

//TODO load setting from JSON file, change settings

class SettingsUpdate implements AppAction {
  final Maybe<Settings> settings;

  SettingsUpdate({required this.settings});

  @override
  AppState updateState(AppState appState) {
    Env.settingsFetcher.writeAppSettings(settings.value);

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: settings)),
      ],
    );
  }
}

class SettingsChangeDefaultLog implements AppAction {
  final Log? log;

  SettingsChangeDefaultLog({this.log});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    Map<String, Log> logs = appState.logsState.logs;
    if (log != null && logs.containsKey(log!.id)) {
      settings = settings.copyWith(defaultLogId: log!.id);
    }

    Env.settingsFetcher.writeAppSettings(settings);

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
      ],
    );
  }
}

class SettingsAddEditCategory implements AppAction {
  final AppCategory category;

  SettingsAddEditCategory({required this.category});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> categories = List.from(settings.defaultCategories);

    if (category.id != null) {
      categories[categories.indexWhere((e) => e.id == category.id)] = category;
    } else {
      categories.add(category.copyWith(id: Uuid().v4()));
    }

    settings = settings.copyWith(defaultCategories: categories);
    Env.settingsFetcher.writeAppSettings(settings);

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
      ],
    );
  }
}

class SettingsDeleteCategory implements AppAction {
  final AppCategory category;

  SettingsDeleteCategory({required this.category});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> categories = List.from(settings.defaultCategories);

    if (canDeleteCategory(id: category.id)) {
      categories = categories.where((element) => element.id != category.id).toList();
      settings = settings.copyWith(defaultCategories: categories);
      Env.settingsFetcher.writeAppSettings(settings);
    }

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
      ],
    );
  }
}

class SettingsAddEditSubcategory implements AppAction {
  final AppCategory subcategory;

  SettingsAddEditSubcategory({required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> subcategories = settings.defaultSubcategories;

    if (subcategory.id != null) {
      subcategories[subcategories.indexWhere((e) => e.id == subcategory.id)] = subcategory;
    } else {
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    }

    settings = settings.copyWith(defaultSubcategories: subcategories);
    Env.settingsFetcher.writeAppSettings(settings);

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
      ],
    );
  }
}

class SettingsDeleteSubcategory implements AppAction {
  final AppCategory subcategory;

  SettingsDeleteSubcategory({required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> subcategories = settings.defaultSubcategories;

    if (canDeleteSubcategory(subcategory: subcategory)) {
      subcategories = subcategories.where((element) => element.id != subcategory.id).toList();
      settings = settings.copyWith(defaultSubcategories: subcategories);
      Env.settingsFetcher.writeAppSettings(settings);
    }
    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
      ],
    );
  }
}

class SettingsSetExpandedCategories implements AppAction {
  AppState updateState(AppState appState) {
    List<bool> expandedCategories = [];
    appState.settingsState.settings.value.defaultCategories.forEach((element) {
      expandedCategories.add(false);
    });

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(expandedCategories: expandedCategories)),
      ],
    );
  }
}

class SettingsExpandCollapseCategory implements AppAction {
  final int index;

  SettingsExpandCollapseCategory({required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.settingsState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(expandedCategories: expandedCategories)),
      ],
    );
  }
}

class SettingsReorderCategory implements AppAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;

  SettingsReorderCategory({required this.oldCategoryIndex, required this.newCategoryIndex});

  AppState updateState(AppState appState) {
    //reorder categories list
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> categories = List.from(settings.defaultCategories);
    categories = reorderLogSettingsCategories(
        categories: categories, oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex);

    //reorder expanded list
    List<bool> expandedCategories = List.from(appState.settingsState.expandedCategories);
    expandedCategories = reorderLogSettingsExpandedCategories(
        expandedCategories: expandedCategories, oldCategoryIndex: oldCategoryIndex, newCategoryIndex: newCategoryIndex);

    settings = settings.copyWith(defaultCategories: categories);
    Env.settingsFetcher.writeAppSettings(settings);

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) =>
            settingsState.copyWith(settings: Maybe<Settings>.some(settings), expandedCategories: expandedCategories)),
      ],
    );
  }
}

class SettingsReorderSubcategory implements AppAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;
  final int oldSubcategoryIndex;
  final int newSubcategoryIndex;

  SettingsReorderSubcategory(
      {required this.oldCategoryIndex,
      required this.newCategoryIndex,
      required this.oldSubcategoryIndex,
      required this.newSubcategoryIndex});

  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    String oldParentId = settings.defaultCategories[oldCategoryIndex].id!;
    String newParentId = settings.defaultCategories[newCategoryIndex].id!;
    List<AppCategory> subcategories = List.from(settings.defaultSubcategories);
    List<AppCategory> subsetOfSubcategories = List.from(settings.defaultSubcategories);
    subsetOfSubcategories
        .retainWhere((subcategory) => subcategory.parentCategoryId == oldParentId); //get initial subset
    AppCategory subcategory = subsetOfSubcategories[oldSubcategoryIndex];

    subcategories = reorderSubcategoriesLogSetting(
        newSubcategoryIndex: newSubcategoryIndex,
        subcategory: subcategory,
        newParentId: newParentId,
        oldParentId: oldParentId,
        subsetOfSubcategories: subsetOfSubcategories,
        subcategories: subcategories);

    settings = settings.copyWith(defaultSubcategories: subcategories);
    Env.settingsFetcher.writeAppSettings(settings);

    return updateSubstates(
      appState,
      [
        updateSettingsState((settingsState) => settingsState.copyWith(settings: Maybe<Settings>.some(settings))),
      ],
    );
  }
}
