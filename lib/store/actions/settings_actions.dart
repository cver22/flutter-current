import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import '../../env.dart';

//TODO load setting from JSON file, change settings

AppState _updateSettingsState(
  AppState appState,
  SettingsState update(SettingsState settingsState),
) {
  return appState.copyWith(settingsState: update(appState.settingsState));
}

class UpdateSettings implements AppAction {
  final Maybe<Settings> settings;

  UpdateSettings({@required this.settings});

  @override
  AppState updateState(AppState appState) {
    Env.settingsFetcher.writeAppSettings(settings.value);

    return _updateSettingsState(
        appState,
        (settingsState) => settingsState.copyWith(
              settings: settings,
            ));
  }
}

class ChangeDefaultLog implements AppAction {
  final Log log;

  ChangeDefaultLog({this.log});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    Map<String, Log> logs = appState.logsState.logs;
    if (log != null && logs.containsKey(log.id)) {
      settings = settings.copyWith(defaultLogId: log.id);
    }

    Env.settingsFetcher.writeAppSettings(settings);

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsAddEditCategory implements AppAction {
  final AppCategory category;

  SettingsAddEditCategory({@required this.category});

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

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsDeleteCategory implements AppAction {
  final AppCategory category;

  SettingsDeleteCategory({@required this.category});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> categories = List.from(settings.defaultCategories);

    if (category.id != NO_CATEGORY) {
      //remove as long as the it is not NO_CATEGORY
      categories = categories.where((element) => element.id != category.id).toList();
      settings = settings.copyWith(defaultCategories: categories);
      Env.settingsFetcher.writeAppSettings(settings);
    }

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsAddEditSubcategory implements AppAction {
  final AppCategory subcategory;

  SettingsAddEditSubcategory({@required this.subcategory});

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

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsDeleteSubcategory implements AppAction {
  final AppCategory subcategory;

  SettingsDeleteSubcategory({@required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> subcategories = settings.defaultSubcategories;

    if (canDeleteSubcategory(subcategory: subcategory)) {
      subcategories = subcategories.where((element) => element.id != subcategory.id).toList();
      settings = settings.copyWith(defaultSubcategories: subcategories);
      Env.settingsFetcher.writeAppSettings(settings);
    }

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SetExpandedSettingsCategories implements AppAction {
  AppState updateState(AppState appState) {
    List<bool> expandedCategories = [];
    appState.settingsState.settings.value.defaultCategories.forEach((element) {
      expandedCategories.add(false);
    });

    return _updateSettingsState(
        appState, (settingsState) => settingsState.copyWith(expandedCategories: expandedCategories));
  }
}

class ExpandCollapseSettingsCategory implements AppAction {
  final int index;

  ExpandCollapseSettingsCategory({@required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.settingsState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return _updateSettingsState(
        appState, (settingsState) => settingsState.copyWith(expandedCategories: expandedCategories));
  }
}

class ReorderCategoryFromSettingsScreen implements AppAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;

  ReorderCategoryFromSettingsScreen({@required this.oldCategoryIndex, @required this.newCategoryIndex});

  AppState updateState(AppState appState) {
    //reorder categories list
    Settings settings = appState.settingsState.settings.value;
    List<AppCategory> categories = List.from(settings.defaultCategories);
    AppCategory movedCategory = categories.removeAt(oldCategoryIndex);
    categories.insert(newCategoryIndex, movedCategory);

    //reorder expanded list
    List<bool> expandedCategories = List.from(appState.settingsState.expandedCategories);
    bool movedExpansion = expandedCategories.removeAt(oldCategoryIndex);
    expandedCategories.insert(newCategoryIndex, movedExpansion);

    return _updateSettingsState(
        appState,
        (settingsState) => settingsState.copyWith(
            settings: Maybe.some(settings.copyWith(defaultCategories: categories)),
            expandedCategories: expandedCategories));
  }
}

class ReorderSubcategoryFromSettingsScreen implements AppAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;
  final int oldSubcategoryIndex;
  final int newSubcategoryIndex;

  ReorderSubcategoryFromSettingsScreen(
      {@required this.oldCategoryIndex,
      @required this.newCategoryIndex,
      @required this.oldSubcategoryIndex,
      @required this.newSubcategoryIndex});

  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    String oldParentId = settings.defaultCategories[oldCategoryIndex].id;
    String newParentId = settings.defaultCategories[newCategoryIndex].id;
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

    return _updateSettingsState(
        appState,
        (settingsState) =>
            settingsState.copyWith(settings: Maybe.some(settings.copyWith(defaultSubcategories: subcategories))));
  }
}
