import 'package:equatable/equatable.dart';

import '../../utils/maybe.dart';
import 'app_settings.dart';

class SettingsState extends Equatable {
  final Maybe<AppSettings> settings;
  final List<bool> expandedCategories;

  SettingsState({
  required this.settings,
  required this.expandedCategories,
  });

  factory SettingsState.initial() {
    return SettingsState(
      settings: Maybe<AppSettings>.none(),
      expandedCategories: const [],
    );
  }

  @override
  List<Object> get props => [settings, expandedCategories];

  @override
  bool get stringify => true;

  SettingsState copyWith({
    Maybe<AppSettings>? settings,
    List<bool>? expandedCategories,
  }) {
    if ((settings == null || identical(settings, this.settings)) &&
        (expandedCategories == null ||
            identical(expandedCategories, this.expandedCategories))) {
      return this;
    }

    return new SettingsState(
      settings: settings ?? this.settings,
      expandedCategories: expandedCategories ?? this.expandedCategories,
    );
  }
}
