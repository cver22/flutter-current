import 'package:equatable/equatable.dart';
import 'package:expenses/currency/models/conversion_rates.dart';
import 'package:meta/meta.dart';

@immutable
class CurrencyState extends Equatable {
  final Map<String, ConversionRates> currenciesMap; //<LogCurrency, ConversionRatesForLogCurrency>

  CurrencyState({this.currenciesMap});

  factory CurrencyState.initial() {
    return CurrencyState(
      currenciesMap: <String, ConversionRates>{},
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [currenciesMap];

  CurrencyState copyWith({
    Map<String, ConversionRates> currenciesMap,
  }) {
    if ((currenciesMap == null || identical(currenciesMap, this.currenciesMap))) {
      return this;
    }

    return new CurrencyState(
      currenciesMap: currenciesMap ?? this.currenciesMap,
    );
  }
}
