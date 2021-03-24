import 'package:equatable/equatable.dart';

import '../../utils/maybe.dart';
import 'settings.dart';

class SettingsState extends Equatable {
  final Maybe<Settings> settings;
  final List<bool> expandedCategories;

  SettingsState({
    this.settings,
    this.expandedCategories,
  });

  factory SettingsState.initial() {
    return SettingsState(
      settings: Maybe<Settings>.none(),
      expandedCategories: const [],
    );
  }

  @override
  List<Object> get props => [settings, expandedCategories];

  @override
  bool get stringify => true;

  SettingsState copyWith({
    Maybe<Settings> settings,
    List<bool> expandedCategories,
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
