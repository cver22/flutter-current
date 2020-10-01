import 'package:equatable/equatable.dart';
import 'package:expenses/env.dart';
import 'package:expenses/models/settings/settings.dart';


class SettingsState extends Equatable {
  final Settings settings;

  SettingsState({
    this.settings,
  });

  factory SettingsState.initial() {
    Env.settingsFetcher.readSettings();
    return SettingsState(
      settings: Env.store.state.settingsState.settings,
    );
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
