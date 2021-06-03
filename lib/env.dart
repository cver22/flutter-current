import 'settings/settings_repository.dart';
import 'currency/currency_local_repository.dart';
import 'currency/currency_remote_repository.dart';
import 'currency/currency_fetcher.dart';
import 'app/models/app_state.dart';
import 'auth_user/user_fetcher.dart';
import 'auth_user/user_repository.dart';
import 'entries/entries_fetcher.dart';
import 'entries/entries_repository.dart';
import 'log/logs_fetcher.dart';
import 'log/logs_repository.dart';
import 'settings/settings_fetcher.dart';
import 'store/app_store.dart';
import 'tags/tag_fetcher.dart';
import 'tags/tag_repository.dart';

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

  static final tagFetcher = TagFetcher(
    store: store,
    tagRepository: FirebaseTagRepository(),
  );

  static final settingsFetcher = SettingsFetcher(
    store: store,
    hiveSettingsRepository: HiveSettingsRepository(),
  ); //SettingsFetcher

  static final currencyFetcher = CurrencyFetcher(
    store: store,
    currencyRemoteRepository: ExchangeRatesApiRepository(),
    currencyLocalRepository: HiveCurrencyRepository(),
  );
}
