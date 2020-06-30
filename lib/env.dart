import 'package:expenses/models/app_state.dart';
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

  //TODO pass the user to the log once a user is obtained
  /*static final logsFetcher = LogsFetcher(
    store: store,
    logsRepository: FirebaseLogsRepository(),
  );*/

}
