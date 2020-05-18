import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:expenses/services/logs_repository.dart';
import 'package:flutter/material.dart';
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
    _logsRepository.addNewLog(event.log);
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
