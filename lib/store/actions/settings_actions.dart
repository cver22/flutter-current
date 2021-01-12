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

class ChangeDefaultLog implements Action {
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
