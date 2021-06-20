import '../utils/db_consts.dart';
import 'package:hive/hive.dart';

import 'settings_model/app_settings.dart';

abstract class SettingsLocalRepository {
  Future<AppSettings?> loadSettings({required String uid});

  Future<void> saveSettings({required AppSettings settings, required String uid});

}

class HiveSettingsRepository extends SettingsLocalRepository {
  @override
  Future<AppSettings?> loadSettings({required String uid}) async {
    print('Retrieving settings from hive');
    var box = Hive.box(SETTINGS_BOX);

    AppSettings? settings = box.get(uid);

    return settings;
  }


  @override
  Future<void> saveSettings({required AppSettings settings, required String uid}) async {
    print('Saving settings to hive');
    var box = Hive.box(SETTINGS_BOX);
    box.put(uid, settings);
  }
}
