import 'package:hive/hive.dart';

import 'currency_local_repository.dart';
import '../store/actions/currency_actions.dart';
import '../store/app_store.dart';
import 'currency_models/conversion_rates.dart';
import 'currency_remote_repository.dart';

class CurrencyFetcher {
  final AppStore _store;
  final CurrencyRemoteRepository _currencyRemoteRepository;
  final CurrencyLocalRepository _currencyLocalRepository;
  final Box? currencyBox;

  CurrencyFetcher({
    required AppStore store,
    required CurrencyRemoteRepository currencyRemoteRepository,
    required CurrencyLocalRepository currencyLocalRepository,
    Box? currencyBox,
  })  : _store = store,
        _currencyRemoteRepository = currencyRemoteRepository,
        _currencyLocalRepository = currencyLocalRepository,
        currencyBox = currencyBox;

  Future<void> remoteLoadReferenceConversionRates({required String referenceCurrency}) async {
    _store.dispatch(CurrencySetLoading());

    _store.dispatch(CurrencySetExchangeRatesFromRemote(
        json: await _currencyRemoteRepository.loadReferenceConversionRates(referenceCurrency: referenceCurrency),
        referenceCurrency: referenceCurrency));
  }

  Future<void> localLoadAllConversionRates() async {
    _store.dispatch(CurrencySetLoading());

    _store.dispatch(CurrencyLoadAllCurrenciesFromLocal(
        localConversionRatesMap: await _currencyLocalRepository.loadAllConversionRates()));
  }

  Future<void> localSaveAllConversionRates({required Map<String, ConversionRates> conversionRateMap}) async {
    //TODO some kind of error checking
    _currencyLocalRepository.saveConversionRates(conversionRateMap: conversionRateMap);
  }
}
