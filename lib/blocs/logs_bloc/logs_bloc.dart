import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:expenses/models/categories/master_categories.dart';
import 'package:expenses/models/categories/my_category/my_category.dart';
import 'package:expenses/models/categories/my_subcategory/my_subcategory.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/services/logs_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../blocs/logs_bloc/bloc.dart';

class LogsBloc extends Bloc<LogsEvent, LogsState> {
  final FirebaseLogsRepository _logsRepository;
  StreamSubscription _logsSubscription;

  LogsBloc({@required LogsRepository logsRepository})
      : assert(logsRepository != null),
        _logsRepository = logsRepository;

  @override
  LogsState get initialState => LogsLoading();

  @override
  Stream<LogsState> mapEventToState(LogsEvent event) async* {
    if (event is LoadLogs) {
      yield* _mapLogsLoadedToState();
    } else if (event is LogAdded) {
      yield* _mapLogAddedToState(event);
    } else if (event is LogUpdated) {
      yield* _mapLogUpdatedToState(event);
    } else if (event is LogDeleted) {
      yield* _mapLogDeletedToState(event);
    } else if (event is LogsUpdated) {
      yield* _mapLogsUpdatedToState(event);
    }
  }

  Stream<LogsState> _mapLogsLoadedToState() async* {
    _logsSubscription?.cancel();
    _logsSubscription = _logsRepository.loadLogs().listen(
          (logs) => add(LogsUpdated(logs: logs)),
        );
  }

  Stream<LogsState> _mapLogAddedToState(LogAdded event) {
    //builds initial categories/subcategories for the log from the person's preferences
    //TODO move this initialization to firebase using a Json file in the app
    Log _log = event.log;
    List<MyCategory> categories = [];
    List<MySubcategory> subcategories = [];

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

    _log = _log.copyWith(categories: categories, subcategories: subcategories);

    print('these are my categories ${_log.categories}');

    _logsRepository.addNewLog(_log);
  }

  Stream<LogsState> _mapLogUpdatedToState(LogUpdated event) {
    _logsRepository.updateLog(event.log);
  }

  Stream<LogsState> _mapLogDeletedToState(LogDeleted event) async* {
    //logs are not deleted, set to inactive and not shown in UI
    _logsRepository.deleteLog(event.log.copyWith(active: false));
  }

  Stream<LogsState> _mapLogsUpdatedToState(LogsUpdated event) async* {
    yield LogsLoaded(event.logs);
  }

  @override
  Future<void> close() {
    _logsSubscription?.cancel();
    return super.close();
  }
}
