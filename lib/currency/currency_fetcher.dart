import 'package:expenses/currency/currency_local_repository.dart';
import 'package:meta/meta.dart';

import '../../expenses/store/app_store.dart';
import 'currency_remote_repository.dart';

class CurrencyFetcher {
  final AppStore _store;
  final CurrencyRemoteRepository _currencyRemoteRepository;
  final CurrencyLocalRepository _currencyLocalRepository;

  CurrencyFetcher({
    @required AppStore store,
    @required CurrencyRemoteRepository currencyRemoteRepository,
    @required CurrencyLocalRepository currencyLocalRepository,
  })  : _store = store,
        _currencyRemoteRepository = currencyRemoteRepository,
        _currencyLocalRepository = currencyLocalRepository;
}
