import '../utils/db_consts.dart';
import 'package:hive/hive.dart';

import 'settings_model/settings.dart';

abstract class SettingsLocalRepository {
  Future<Settings?> loadSettings();

  Future<void> saveSettings({required Settings settings});

  Future<bool> settingsInitialized();
}

class HiveSettingsRepository extends SettingsLocalRepository {
  @override
  Future<Settings?> loadSettings() async {
    var box = Hive.box(SETTINGS_BOX);

    Settings? settings = box.get(SETTINGS_HIVE_INDEX);

    print('Retrieving settings from hive: $settings');

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
  Future<void> saveSettings({required Settings settings}) async {
    print('Saving settings to hive');
    var box = Hive.box(SETTINGS_BOX);
    box.put(SETTINGS_HIVE_INDEX, settings);
    box.put(SETTINGS_INITIALIZED_INDEX, true);
  }
}
