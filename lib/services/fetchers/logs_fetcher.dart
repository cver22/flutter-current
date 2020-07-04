import 'dart:async';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/services/logs_repository.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
    _logsSubscription =
        _logsRepository.loadLogs(_store.state.authState.user.value).listen(
              (logs) => _store.dispatch(SetLogs(logList: logs)),
            );
    _store.dispatch(SetLogsLoaded());
  }

  //TODO need updateLog method

  Future<void> addLog(Log log) async {
    Log _log = log;
    List<MyCategory> categories = [];
    List<MySubcategory> subcategories = [];

    // Sample subcategories, later sample to be retrieved from JSON
    categories.add(MyCategory(name: 'Home', id: Uuid().v4()));
    categories.add(MyCategory(name: 'Transportation', id: Uuid().v4()));

    subcategories.add(MySubcategory(
        name: 'Rent',
        id: Uuid().v4(),
        parentCategoryId:
            categories.firstWhere((element) => element.name == 'Home').id));

    subcategories.add(MySubcategory(
        name: 'Utilities',
        id: Uuid().v4(),
        parentCategoryId:
            categories.firstWhere((element) => element.name == 'Home').id));

    subcategories.add(MySubcategory(
        name: 'Car',
        id: Uuid().v4(),
        parentCategoryId: categories
            .firstWhere((element) => element.name == 'Transportation')
            .id));

    subcategories.add(MySubcategory(
        name: 'Bus',
        id: Uuid().v4(),
        parentCategoryId: categories
            .firstWhere((element) => element.name == 'Transportation')
            .id));

    subcategories.add(MySubcategory(
        name: 'Parking',
        id: Uuid().v4(),
        parentCategoryId: categories
            .firstWhere((element) => element.name == 'Transportation')
            .id));

    _log = _log.copyWith(uid: _store.state.authState.user.value.id, categories: categories, subcategories: subcategories);

    print('these are my categories ${_log.categories}');

    try {
      _logsRepository.addNewLog(_store.state.authState.user.value, _log);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateLog(Log log) async {
    _store.dispatch(ClearSelectedLog());
    try{
      _logsRepository.updateLog(
          _store.state.authState.user.value, log);
    } catch (e) {
      print(e.toString());
    }

  }

  Future<void> deleteLog(Log log) async {
    _store.dispatch(ClearSelectedLog());
    try {
      _logsRepository.deleteLog(
          _store.state.authState.user.value, log.copyWith(active: false));
    }catch (e) {
      print(e.toString());
    }
  }

  //TODO where to close the subscription when exiting the app?
  Future<void> close() async {
    _logsSubscription?.cancel();
  }
}
