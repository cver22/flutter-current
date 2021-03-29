import 'package:currency_picker/currency_picker.dart';
import 'package:equatable/equatable.dart';
import '../../currency/currency_models/conversion_rates.dart';
import 'package:meta/meta.dart';

@immutable
class CurrencyState extends Equatable {
  final Map<String, ConversionRates> conversionRateMap; //<LogCurrency, ConversionRatesForLogCurrency>
  final List<Currency> allCurrencies;
  final List<Currency> searchCurrencies;
  final bool isLoading;

  CurrencyState({
    this.conversionRateMap = const {},
    this.allCurrencies = const [],
    this.searchCurrencies = const [],
    this.isLoading = false,
  });

  factory CurrencyState.initial() {
    return CurrencyState(
      conversionRateMap: <String, ConversionRates>{},
      //TODO remove temporary restriction of currency types when implementing full currency api
      allCurrencies: CurrencyService().getAll()
        ..retainWhere((element) =>
            element.code.contains('CAD') ||
            element.code.contains('ISK') ||
            element.code.contains('PHP') ||
            element.code.contains('DKK') ||
            element.code.contains('HUF') ||
            element.code.contains('CZK') ||
            element.code.contains('GBP') ||
            element.code.contains('RON') ||
            element.code.contains('SEK') ||
            element.code.contains('IDR') ||
            element.code.contains('INR') ||
            element.code.contains('BRL') ||
            element.code.contains('RUB') ||
            element.code.contains('HRK') ||
            element.code.contains('JPY') ||
            element.code.contains('THB') ||
            element.code.contains('CHF') ||
            element.code.contains('EUR') ||
            element.code.contains('MYR') ||
            element.code.contains('BGN') ||
            element.code.contains('TRY') ||
            element.code.contains('CNY') ||
            element.code.contains('NOK') ||
            element.code.contains('NZD') ||
            element.code.contains('ZAR') ||
            element.code.contains('USD') ||
            element.code.contains('MXN') ||
            element.code.contains('SGD') ||
            element.code.contains('AUD') ||
            element.code.contains('ILS') ||
            element.code.contains('KRW') ||
            element.code.contains('PLN'))
        ..sort((a, b) => a.code.compareTo(b.code)),
      searchCurrencies: <Currency>[],
      isLoading: false,
    );
  }

  @override
  List<Object> get props => [conversionRateMap, allCurrencies, searchCurrencies, isLoading];

  CurrencyState copyWith({
    Map<String, ConversionRates> conversionRateMap,
    List<Currency> allCurrencies,
    List<Currency> searchCurrencies,
    bool isLoading,
  }) {
    if ((conversionRateMap == null || identical(conversionRateMap, this.conversionRateMap)) &&
        (allCurrencies == null || identical(allCurrencies, this.allCurrencies)) &&
        (searchCurrencies == null || identical(searchCurrencies, this.searchCurrencies)) &&
        (isLoading == null || identical(isLoading, this.isLoading))) {
      return this;
    }

    return new CurrencyState(
      conversionRateMap: conversionRateMap ?? this.conversionRateMap,
      allCurrencies: allCurrencies ?? this.allCurrencies,
      searchCurrencies: searchCurrencies ?? this.searchCurrencies,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
