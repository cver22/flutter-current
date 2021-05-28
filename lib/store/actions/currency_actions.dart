import 'package:currency_picker/currency_picker.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../utils/maybe.dart';
import '../../currency/currency_models/conversion_rates.dart';
import '../../app/models/app_state.dart';
import 'app_actions.dart';

class CurrencyLoadAllCurrenciesFromLocal implements AppAction {
  final Map<String, ConversionRates>? localConversionRatesMap;

  CurrencyLoadAllCurrenciesFromLocal({this.localConversionRatesMap});

  //pulls exchange rates from hive if present, otherwise provides 0.0
  AppState updateState(AppState appState) {
    Map<String, Log> logs = Map<String, Log>.from(appState.logsState.logs);
    Map<String, ConversionRates> conversionRateMap =
        Map<String, ConversionRates>.from(appState.currencyState.conversionRateMap);
    List<Currency> allCurrencies = List<Currency>.from(appState.currencyState.allCurrencies);

    logs.forEach((key, log) {
      String referenceCurrency = log.currency!;

      ConversionRates conversionRates =
          mapConversionRates(referenceCurrency: referenceCurrency, allCurrencies: allCurrencies);

      conversionRateMap.update(referenceCurrency, (value) => conversionRates, ifAbsent: () => conversionRates);
    });

    //if local repository has rates, load those rates
    if (localConversionRatesMap != null) {
      localConversionRatesMap!.forEach((reference, conversionRates) {
        if (conversionRateMap.containsKey(reference) && conversionRates.rates.isNotEmpty) {
          conversionRateMap.update(reference, (value) => conversionRates, ifAbsent: () => conversionRates);
        }
      });
    }

    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(
              conversionRateMap: conversionRateMap,
              isLoading: false,
            )),
      ],
    );
  }
}

class CurrencySearchCurrencies implements AppAction {
  final String search;
  final List<Currency>? currencies;

  CurrencySearchCurrencies({
    required this.search,
    this.currencies,
  });

  AppState updateState(AppState appState) {
    List<Currency> searchCurrencies = <Currency>[];
    Maybe<String> searchMaybe = Maybe.none();
    List<Currency>? passedCurrencies;

    if (currencies != null) {
      passedCurrencies = List<Currency>.from(currencies!);
    }

    if (search.isNotEmpty) {
      searchCurrencies = passedCurrencies ?? List<Currency>.from(appState.currencyState.allCurrencies)
        ..retainWhere((element) =>
            element.name.toLowerCase().contains(search.toLowerCase()) ||
            element.code.toLowerCase().contains(search.toLowerCase()));
      searchMaybe = Maybe.some(search);
    }

    return updateSubstates(
      appState,
      [
        updateCurrencyState(
            (currencyState) => currencyState.copyWith(searchCurrencies: searchCurrencies, search: searchMaybe)),
      ],
    );
  }
}

class CurrencyClearSearch implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(
              search: Maybe<String>.none(),
              searchCurrencies: <Currency>[],
            )),
      ],
    );
  }
}

class CurrencySetLoading implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(
              isLoading: true,
            )),
      ],
    );
  }
}

class CurrencySetExchangeRatesFromRemote implements AppAction {
  final Map<String, dynamic>? json;
  final String referenceCurrency;

  CurrencySetExchangeRatesFromRemote({required this.json, required this.referenceCurrency});

  @override
  AppState updateState(AppState appState) {
    Map<String, ConversionRates> conversionRateMap =
        Map<String, ConversionRates>.from(appState.currencyState.conversionRateMap);
    List<Currency> allCurrencies = List<Currency>.from(appState.currencyState.allCurrencies);

    ConversionRates conversionRates =
        mapConversionRates(referenceCurrency: referenceCurrency, allCurrencies: allCurrencies, json: json);

    conversionRateMap.update(referenceCurrency, (value) => conversionRates, ifAbsent: () => conversionRates);

    //save to local
    Env.currencyFetcher.localSaveAllConversionRates(conversionRateMap: conversionRateMap);

    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(
              conversionRateMap: conversionRateMap,
              isLoading: false,
            )),
      ],
    );
  }
}

ConversionRates mapConversionRates(
    {required String referenceCurrency, required List<Currency> allCurrencies, Map<String, dynamic>? json}) {
  Map<String, double> rates = Map<String, double>();
  DateTime? dateUpdated;

  allCurrencies.forEach((currency) {
    double conversionRate = 0.0;
    if (json != null) {
      var jsonConversionRate = json['conversion_rates'][currency.code];

      //error checking to prevent attempting to convert null return from json for a particular currency
      if (jsonConversionRate != null) {
        conversionRate = jsonConversionRate.toDouble();
      }
    }
    rates.update(currency.code, (value) => conversionRate, ifAbsent: () => conversionRate);
  });

  if (json != null) {
    dateUpdated = DateTime.fromMillisecondsSinceEpoch(json['time_last_update_unix'].toInt() * 1000);
  }
  return ConversionRates(lastUpdated: dateUpdated, rates: rates);
}
