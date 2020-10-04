import 'package:equatable/equatable.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/settings/settings.dart';


class SettingsState extends Equatable {
  final Settings settings;

  SettingsState({
    this.settings,
  });

  factory SettingsState.initial() {
    List<MyCategory> categories = [];
    List<MySubcategory> subcategories = [];
    //Env.settingsFetcher.readSettings();
    return SettingsState(
      settings: Settings(homeCurrency: null, defaultLogId: null, defaultSubcategories: subcategories, defaultCategories: categories),
      //settings: Env.store.state.settingsState.settings,
    );
    //TODO some sort of error handling if there are no settings values
  }

  SettingsState copyWith({
    Settings settings,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object> get props => [settings];

  @override
  bool get stringify => true;
}
