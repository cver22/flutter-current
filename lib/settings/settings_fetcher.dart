import 'dart:convert';
import '../settings/settings_repository.dart';
import 'package:flutter/services.dart';

import '../env.dart';
import '../store/actions/settings_actions.dart';
import '../store/app_store.dart';
import '../utils/maybe.dart';
import 'settings_model/app_settings.dart';
import 'settings_model/settings_entity.dart';

class SettingsFetcher {
  final AppStore _store;
  final HiveSettingsRepository _hiveSettingsRepository;

  SettingsFetcher({required AppStore store, required HiveSettingsRepository hiveSettingsRepository})
      : _store = store,
        _hiveSettingsRepository = hiveSettingsRepository;

  Future<void> writeAppSettings(AppSettings settings) async {
    _hiveSettingsRepository.saveSettings(settings: settings);
  }

  Future<void> readResetAppSettings({bool resetSettings = false}) async {
    bool settingsInitialized = await _hiveSettingsRepository.settingsInitialized();

    if (resetSettings) {
      settingsInitialized = false;
    }

    if (settingsInitialized && Env.store.state.settingsState.settings.isSome) {
      print('settings are loaded');
      //if the settings are already loaded, do nothing
      return;
    } else if (!settingsInitialized || resetSettings) {
      print('Load/Reload default settings');
      //if no settings have ever been loaded, load the default
      String jsonString = await rootBundle.loadString('assets/default_settings.txt');
      AppSettings settings = AppSettings.fromEntity(SettingsEntity.fromJson(json.decode(jsonString)));

      //load default settings to app
      _store.dispatch(SettingsUpdate(settings: Maybe.some(settings.copyWith(logOrder: <String>[]))));
    } else {
      print('Load settings');
      //load or reloads hive settings
      AppSettings? settings = await _hiveSettingsRepository.loadSettings();
      if (settings != null) {
        _store.dispatch(SettingsUpdate(settings: Maybe.some(settings)));
      } else {
        _store.dispatch(SettingsUpdate(settings: Maybe.none()));
      }
    }
  }
}
