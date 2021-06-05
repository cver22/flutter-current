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
        localConversionRatesMap: await _currencyLocalRepository.loadAllConversionRates()));
  }

  Future<void> localSaveConversionRates({required Map<String, ConversionRates> conversionRateMap}) async {
    _currencyLocalRepository.saveConversionRates(conversionRateMap: conversionRateMap);
  }

  Future<void> loadAllConversionRates() async {
    //loads rates for all logs and settings from local unless not present, then load from remote
    _store.dispatch(CurrencySetLoading());
    Map<String, Log> logs = _store.state.logsState.logs;
    List<String> currencies = <String>[];
    Map<String, ConversionRates> conversionRatesMap = await _currencyLocalRepository.loadAllConversionRates();
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

    currencies.forEach((currency) async {
      if (!conversionRatesMap.containsKey(currency)) {
        ConversionRates conversionRates = await _currencyRemoteRepository.loadReferenceConversionRates(
          allCurrencies: _store.state.currencyState.allCurrencies,
          referenceCurrency: currency,
        );
        conversionRatesMap.update(currency, (value) => conversionRates, ifAbsent: () => conversionRates);
      }
    });

    _store.dispatch(CurrencyLoadAllCurrenciesFromLocal(localConversionRatesMap: conversionRatesMap));
  }
}
