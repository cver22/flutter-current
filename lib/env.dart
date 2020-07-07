import 'package:expenses/models/app_state.dart';
import 'package:expenses/services/entries_repository.dart';
import 'package:expenses/services/fetchers/entries_fetcher.dart';
import 'package:expenses/services/fetchers/logs_fetcher.dart';
import 'package:expenses/services/logs_repository.dart';
import 'file:///D:/version-control/flutter/expenses/lib/services/fetchers/user_fetcher.dart';
import 'package:expenses/services/user_repository.dart';
import 'package:expenses/store/app_store.dart';

class Env {
  static final store = AppStore(AppState.initial());

  static final userFetcher = UserFetcher(
    store: store,
    userRepository: FirebaseUserRepository(),
  );

  static final logsFetcher = LogsFetcher(
    store: store,
    logsRepository: FirebaseLogsRepository(),
  );

  static final entriesFetcher = EntriesFetcher(
    store: store,
    entriesRepository: FirebaseEntriesRepository(),
  );
}
