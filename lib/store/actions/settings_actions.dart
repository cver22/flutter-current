part of 'actions.dart';

//TODO load setting from JSON file, change settings

AppState _updateSettingsState(
  AppState appState,
  SettingsState update(SettingsState settingsState),
) {
  return appState.copyWith(settingsState: update(appState.settingsState));
}

class UpdateSettings implements Action {
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
