import 'dart:convert';
import 'dart:io';
import 'package:expenses/models/settings/settings.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

class SettingsFetcher {
  final AppStore _store;

  SettingsFetcher({
    @required AppStore store,
  }) : _store = store;

  //TODO create setter and getter to the JSON file

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.txt');
  }

  Future<void> writeSettings(Settings settings) async {
    final file = await _localFile;
    try {
      // Write settings to file from store.
      file.writeAsString('${settings.toEntity().toJson()}');
    } catch (e) {
      print('Error writing settings');
    }
  }

  Future<void> readSettings() async {
    try {
      final file = await _localFile;

      // Read settings to file.
      String settings = await file.readAsString();

      _store.dispatch(
        UpdateSettings(
          settings: Settings.fromEntity(json.decode(settings)),
        ),
      );
    } catch (e) {
      // If encountering an error
      print('Error reading settings');
    }
  }
}
