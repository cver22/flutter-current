import 'dart:convert';
import '../settings/settings_repository.dart';
import 'package:flutter/services.dart';

import '../env.dart';
import '../store/actions/settings_actions.dart';
import '../store/app_store.dart';
import '../utils/maybe.dart';
import 'settings_model/settings.dart';
import 'settings_model/settings_entity.dart';

class SettingsFetcher {
  final AppStore _store;
  final HiveSettingsRepository _hiveSettingsRepository;

  SettingsFetcher({required AppStore store, required HiveSettingsRepository hiveSettingsRepository})
      : _store = store,
        _hiveSettingsRepository = hiveSettingsRepository;

  Future<void> writeAppSettings(Settings settings) async {
    _hiveSettingsRepository.saveSettings(settings: settings);
  }

  Future<void> readResetAppSettings({ bool resetSettings = false}) async {
    bool settingsInitialized = (await _hiveSettingsRepository.settingsInitialized());

    if (resetSettings) {
      settingsInitialized = false;
    }

    if (settingsInitialized && Env.store.state.settingsState.settings.isSome && resetSettings) {
      //if the settings are already loaded, do nothing
      return;
    } else if (!settingsInitialized) {
      print('Resetting settings');
      //if no settings have ever been loaded, load the default
      String jsonString = await rootBundle.loadString('assets/default_settings.txt');
      Settings settings = Settings.fromEntity(SettingsEntity.fromJson(json.decode(jsonString)));

      //load default settings to app
      _store.dispatch(SettingsUpdate(settings: Maybe.some(settings)));

      //initialize settings to hive
      _hiveSettingsRepository.saveSettings(settings: settings);
    } else {
      //loads hive settings
      Settings? settings = await _hiveSettingsRepository.loadSettings();
      if ( settings != null) {
        _store.dispatch(SettingsUpdate(settings: Maybe.some(settings)));
      }  else {
        _store.dispatch(SettingsUpdate(settings: Maybe.none()));
      }

    }
  }
}
