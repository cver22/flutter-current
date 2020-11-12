import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/auth_user/user_repository.dart';
import 'package:expenses/auth_user/user_fetcher.dart';
import 'package:expenses/entry/entries_fetcher.dart';
import 'package:expenses/entry/entries_repository.dart';
import 'package:expenses/log/logs_fetcher.dart';
import 'package:expenses/log/logs_repository.dart';
import 'package:expenses/settings/settings_fetcher.dart';
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

  static final settingsFetcher = SettingsFetcher(store: store); //SettingsFetcher
}
