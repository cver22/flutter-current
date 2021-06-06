import '../utils/db_consts.dart';
import 'package:hive/hive.dart';

import 'settings_model/app_settings.dart';

abstract class SettingsLocalRepository {
  Future<AppSettings?> loadSettings();

  Future<void> saveSettings({required AppSettings settings});

  Future<bool> settingsInitialized();
}

class HiveSettingsRepository extends SettingsLocalRepository {
  @override
  Future<AppSettings?> loadSettings() async {
    print('Retrieving settings from hive');
    var box = Hive.box(SETTINGS_BOX);

    AppSettings? settings = box.get(SETTINGS_HIVE_INDEX);

    return settings;
  }

  @override
  Future<bool> settingsInitialized() async {
    var box = Hive.box(SETTINGS_BOX);

    bool initialized = box.get(SETTINGS_INITIALIZED_INDEX) ?? false;

    print('Settings initialized: $initialized');

    return initialized;
  }

  @override
  Future<void> saveSettings({required AppSettings settings}) async {
    print('Saving settings to hive');
    var box = Hive.box(SETTINGS_BOX);
    box.put(SETTINGS_HIVE_INDEX, settings);
    box.put(SETTINGS_INITIALIZED_INDEX, true);
  }
}
