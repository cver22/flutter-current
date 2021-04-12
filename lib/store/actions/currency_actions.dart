import 'package:currency_picker/currency_picker.dart';
import '../../currency/currency_models/conversion_rates.dart';
import 'package:meta/meta.dart';
import '../../app/models/app_state.dart';
import 'app_actions.dart';

class CurrencyInitializeCurrencies implements AppAction {
  //TODO will be used to pull exchange rates from sqflite
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith()),
      ],
    );
  }
}

class CurrencySearchCurrencies implements AppAction {
  final String search;

  CurrencySearchCurrencies({@required this.search});

  AppState updateState(AppState appState) {
    List<Currency> searchCurrencies = <Currency>[];

    if (search.isNotEmpty) {
      searchCurrencies = List<Currency>.from(appState.currencyState.allCurrencies)
        ..retainWhere((element) =>
            element.name.toLowerCase().contains(search.toLowerCase()) ||
            element.code.toLowerCase().contains(search.toLowerCase()));
    }

    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(searchCurrencies: searchCurrencies)),
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
        updateCurrencyState((currencyState) => currencyState.copyWith()),
      ],
    );
  }
}

class CurrencySetLoaded implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith()),
      ],
    );
  }
}

class CurrencySetExchangeRatesFromRemote implements AppAction {
  final Map<String, dynamic> json;
  final String referenceCurrency;

  CurrencySetExchangeRatesFromRemote({@required this.json, @required this.referenceCurrency});

  @override
  AppState updateState(AppState appState) {
    //print(json);
    Map<String, ConversionRates> conversionRateMap =
        Map<String, ConversionRates>.from(appState.currencyState.conversionRateMap);
    Map<String, double> rates = Map<String, double>();
    List<Currency> allCurrencies = appState.currencyState.allCurrencies;

    allCurrencies.forEach((currency) {
      double conversionRate = json['conversion_rates'][currency.code].toDouble();

      rates.update(currency.code, (value) => conversionRate, ifAbsent: () => conversionRate);
    });

    ConversionRates conversionRates = ConversionRates(
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['time_last_update_unix'].toInt() * 1000), rates: rates);

    print('rates: $conversionRates');

    conversionRateMap.update(referenceCurrency, (value) => conversionRates, ifAbsent: () => conversionRates);

    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(
              conversionRateMap: conversionRateMap,
            )),
      ],
    );
  }
}
