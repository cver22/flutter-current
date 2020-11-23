import 'dart:async';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/categories/categories_model/my_subcategory/my_subcategory.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/logs_repository.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/utils/maybe.dart';

class LogsFetcher {
  final AppStore _store;
  final LogsRepository _logsRepository;
  StreamSubscription _logsSubscription;

  LogsFetcher({
    @required AppStore store,
    @required LogsRepository logsRepository,
  })  : _store = store,
        _logsRepository = logsRepository;

  Future<void> loadLogs() async {
    _store.dispatch(SetLogsLoading());
    _logsSubscription?.cancel();
    _logsSubscription = _logsRepository.loadLogs(_store.state.authState.user.value).listen(
          (logs) => _store.dispatch(SetLogs(logList: logs)),
        );
    _store.dispatch(SetLogsLoaded());
  }

  Future<void> addLog(Log log) async {
    Log _log = log;
    List<MyCategory> categories = Env.store.state.settingsState.settings.value.defaultCategories;
    List<MySubcategory> subcategories = Env.store.state.settingsState.settings.value.defaultSubcategories;
    List<Tag> tags = [];

    _log =
        _log.copyWith(uid: _store.state.authState.user.value.id, categories: categories, subcategories: subcategories, tags: tags);


    try {
      _logsRepository.addNewLog(_store.state.authState.user.value, _log);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateLog(Log log) async {
    _store.dispatch(ClearSelectedLog());
    try {
      _logsRepository.updateLog(_store.state.authState.user.value, log);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteLog(Log log) async {
    //TODO need error checking if this log is the default log, need to make another log the default log
    _store.dispatch(ClearSelectedLog());
    try {
      SettingsState settings = SettingsState(settings: _store.state.settingsState.settings);

      //ensures the default log is updated if the current log is default and deleted
      if (settings.settings.value.defaultLogId == log.id) {
        Env.store.dispatch(UpdateSettings(
            settings: Maybe.some(settings.settings.value.copyWith(
                defaultLogId: _store.state.logsState.logs.values.firstWhere((element) => element.id != log.id).id))));
      }
      _logsRepository.updateLog(_store.state.authState.user.value, log.copyWith(active: false));
    } catch (e) {
      print(e.toString());
    }
  }

  //TODO where to close the subscription when exiting the app?
  Future<void> close() async {
    _logsSubscription?.cancel();
  }
}
