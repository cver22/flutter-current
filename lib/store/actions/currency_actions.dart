import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/utils/maybe.dart';
import '../../currency/currency_models/conversion_rates.dart';
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

class CurrencySetLoaded implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(
              isLoading: false,
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
    Map<String, double> rates = Map<String, double>();
    List<Currency> allCurrencies = appState.currencyState.allCurrencies;

    allCurrencies.forEach((currency) {
      var jsonConversionRate = json!['conversion_rates'][currency.code];

      //error checking to prevent attempting to convert null return from json for a particular currency
      if (jsonConversionRate != null) {
        double conversionRate = jsonConversionRate.toDouble();

        rates.update(currency.code, (value) => conversionRate, ifAbsent: () => conversionRate);
      }
    });

    ConversionRates conversionRates = ConversionRates(
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(json!['time_last_update_unix'].toInt() * 1000), rates: rates);

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
