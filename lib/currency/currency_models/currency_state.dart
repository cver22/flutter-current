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
    required this.conversionRateMap,
  required this.allCurrencies,
  required this.searchCurrencies,
  required this.isLoading,
  });

  factory CurrencyState.initial() {
    return CurrencyState(
      conversionRateMap: <String, ConversionRates>{},
      allCurrencies: CurrencyService().getAll()
        ..removeWhere((element) => element.code.contains('BI') || element.code.contains('VEF'))
        ..sort((a, b) => a.code.compareTo(b.code)),
      //removes currencies not available in current conversion API and sorts alphabetically
      searchCurrencies: <Currency>[],
      isLoading: false,
    );
  }

  @override
  List<Object> get props => [conversionRateMap, allCurrencies, searchCurrencies, isLoading];

  CurrencyState copyWith({
    Map<String, ConversionRates>? conversionRateMap,
    List<Currency>? allCurrencies,
    List<Currency>? searchCurrencies,
    bool? isLoading,
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
