import 'package:meta/meta.dart';

import 'currency_local_repository.dart';
import '../store/actions/currency_actions.dart';
import '../store/app_store.dart';
import 'currency_remote_repository.dart';

class CurrencyFetcher {
  final AppStore _store;
  final CurrencyRemoteRepository _currencyRemoteRepository;
  //final CurrencyLocalRepository _currencyLocalRepository;

  CurrencyFetcher({
    @required AppStore store,
    @required CurrencyRemoteRepository currencyRemoteRepository,
    //@required CurrencyLocalRepository currencyLocalRepository,
  })  : _store = store,
        _currencyRemoteRepository = currencyRemoteRepository/*,
        _currencyLocalRepository = currencyLocalRepository*/;

  Future<void> loadRemoteConversionRates({@required String referenceCurrency}) async {
    _store.dispatch(CurrencySetLoading());

    var json = await _currencyRemoteRepository.loadConversionRates(referenceCurrency: referenceCurrency);

    print(json);

    _store.dispatch(CurrencySetLoaded());
  }
}
