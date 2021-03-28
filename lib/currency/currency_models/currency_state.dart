import 'package:currency_picker/currency_picker.dart';
import 'package:equatable/equatable.dart';
import 'package:expenses/currency/currency_models/conversion_rates.dart';
import 'package:meta/meta.dart';

@immutable
class CurrencyState extends Equatable {
  final Map<String, ConversionRates> conversionRateMap; //<LogCurrency, ConversionRatesForLogCurrency>
  final List<Currency> allCurrencies;
  final List<Currency> searchCurrencies;

  CurrencyState({
    this.conversionRateMap = const {},
    this.allCurrencies = const [],
    this.searchCurrencies = const [],
  });

  factory CurrencyState.initial() {
    return CurrencyState(
      conversionRateMap: <String, ConversionRates>{},
      allCurrencies: CurrencyService().getAll()..sort((a, b) => a.code.compareTo(b.code)),
      searchCurrencies: <Currency>[],

    );
  }

  @override
  List<Object> get props => [conversionRateMap, allCurrencies, searchCurrencies];

  CurrencyState copyWith({
    Map<String, ConversionRates> conversionRateMap,
    List<Currency> allCurrencies,
    List<Currency> searchCurrencies,
  }) {
    if ((conversionRateMap == null || identical(conversionRateMap, this.conversionRateMap)) &&
        (allCurrencies == null || identical(allCurrencies, this.allCurrencies)) &&
        (searchCurrencies == null || identical(searchCurrencies, this.searchCurrencies))) {
      return this;
    }

    return new CurrencyState(
      conversionRateMap: conversionRateMap ?? this.conversionRateMap,
      allCurrencies: allCurrencies ?? this.allCurrencies,
      searchCurrencies: searchCurrencies ?? this.searchCurrencies,
    );
  }


}
