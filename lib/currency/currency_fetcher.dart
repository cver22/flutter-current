import 'package:expenses/log/log_model/log.dart';
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
        conversionRates: await _currencyRemoteRepository.loadReferenceConversionRates(
          allCurrencies: _store.state.currencyState.allCurrencies,
          referenceCurrency: referenceCurrency,
        ),
        referenceCurrency: referenceCurrency));
  }

  Future<void> localLoadConversionRates() async {
    _store.dispatch(CurrencySetLoading());

    _store.dispatch(CurrencyLoadAllCurrenciesFromLocal(
        localConversionRatesMap: await _currencyLocalRepository.loadAllConversionRates(uid: _store.state.authState.user.value.id)));
  }

  Future<void> localSaveConversionRates({required Map<String, ConversionRates> conversionRatesMap}) async {
    _currencyLocalRepository.saveConversionRates(conversionRateMap: conversionRatesMap, uid: _store.state.authState.user.value.id);
  }

  Future<void> loadConversionRates({required Map<String, Log> logs}) async {
    print('load all conversion rates');
    //loads rates for all logs and settings from local unless not present, then load from remote
    _store.dispatch(CurrencySetLoading());
    List<String> currencies = <String>[];
    Map<String, ConversionRates> conversionRatesMap = await _currencyLocalRepository.loadAllConversionRates(uid: _store.state.authState.user.value.id);
    bool writeToStorage = false;
    String? settingsCurrency;

    if (_store.state.settingsState.settings.isSome) {
      settingsCurrency = _store.state.settingsState.settings.value.homeCurrency;
      currencies.add(settingsCurrency);
    }

    logs.forEach((key, log) {
      if (log.currency != settingsCurrency) {
        currencies.add(log.currency!);
      }
    });

    //remotely loads any previously unloaded currencies
    for (String referenceCurrency in currencies) {
      if (!conversionRatesMap.containsKey(referenceCurrency)) {
        await _currencyRemoteRepository
            .loadReferenceConversionRates(
          allCurrencies: _store.state.currencyState.allCurrencies,
          referenceCurrency: referenceCurrency,
        )
            .then((conversionRates) {
          conversionRatesMap.update(referenceCurrency, (value) => conversionRates, ifAbsent: () => conversionRates);
          writeToStorage = true;
        });
      }
    }

    //write to local in loading new rates
    if (writeToStorage) {
      localSaveConversionRates(conversionRatesMap: conversionRatesMap);
    }

    _store.dispatch(CurrencyLoadAllCurrenciesFromLocal(localConversionRatesMap: conversionRatesMap));
  }
}
