import 'dart:async';
import '../store/actions/logs_actions.dart';
import '../store/app_store.dart';
import 'log_model/log.dart';
import 'logs_repository.dart';

class LogsFetcher {
  final AppStore _store;
  final LogsRepository _logsRepository;
  StreamSubscription? _logsSubscription;

  LogsFetcher({
    required AppStore store,
    required LogsRepository logsRepository,
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

  Future<void> addLog(Log log) async {
    try {
      _logsRepository.addNewLog(log);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> updateLog(Log? log) async {
    try {
      _logsRepository.updateLog(log);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteLog({required Log? log}) async {
    try {
      _logsRepository.deleteLog(log);
    } catch (e) {
      print(e.toString());
    }
  }

  //TODO where to close the subscription when exiting the app?
  Future<void> close() async {
    _logsSubscription?.cancel();
  }
}
