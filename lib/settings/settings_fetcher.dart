import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:expenses/env.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/settings/settings_model/settings_entity.dart';
import 'package:expenses/store/actions/settings_actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsFetcher {
  final AppStore _store;

  SettingsFetcher({
    @required AppStore store,
  }) : _store = store;

  //TODO create setter and getter to the JSON file
  //TODO separate repository and fetchers

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    bool fileExists = await File(path).exists();

    if (!fileExists) {
      File('$path/settings.txt').create(recursive: true);
    }

    return File('$path/settings.txt');
  }

  Future<void> writeAppSettings(Settings settings) async {
    final file = await _localFile;
    try {
      // Write settings to file from store as a json.
      file.writeAsString(json.encode(settings.toEntity().toJson()));
    } catch (e) {
      print('Error writing settings: ${e.toString()}');
    }
  }

  Future<void> readResetAppSettings({bool resetSettings}) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    //determines if this is the first instance the user has logged in and sets the default settings
    bool settingsInitialized = (prefs.getBool('settings_initialized') ?? false);

    if (resetSettings) {
      settingsInitialized = false;
    }

    try {
      if (settingsInitialized && Env.store.state.settingsState.settings.isSome) {
        //if the settings are already loaded, do nothing
        return;
      } else if (!settingsInitialized) {
        print('Resetting settings');
        //if no settings have ever been loaded, load the default
        String jsonString = await rootBundle.loadString('assets/default_settings.txt');

        _store.dispatch(UpdateSettings(
          settings: Maybe.some(Settings.fromEntity(SettingsEntity.fromJson(json.decode(jsonString)))),
        ));

        //marks that default settings have previously been read from assets
        prefs.setBool('settings_initialized', true);
      } else {
        //reads the settings from the saved file to reload them if they are not yet loaded
        final file = await _localFile;

        Map<String, dynamic> jsonData = LinkedHashMap();
        jsonData = json.decode(await file.readAsString());

        _store.dispatch(UpdateSettings(
          settings: Maybe.some(Settings.fromEntity(SettingsEntity.fromJson(jsonData))),
        ));
      }
    } catch (e) {
      // If encountering an error
      print('Error reading settings ${e.toString()}');
    }
  }
}
