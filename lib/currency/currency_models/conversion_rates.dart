import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class ConversionRates extends Equatable {
  final Map<String, double> rates; // Currency to convert from to log currency and rate
  final DateTime lastUpdated;

  ConversionRates({
    this.rates = const {},
    @required this.lastUpdated,
  });

  @override
  List<Object> get props => [rates, lastUpdated];

  @override
  bool get stringify => true;

  ConversionRates copyWith({
    Map<String, double> conversionRates,
    DateTime lastUpdated,
  }) {
    if ((conversionRates == null || identical(conversionRates, this.rates)) &&
        (lastUpdated == null || identical(lastUpdated, this.lastUpdated))) {
      return this;
    }

    return new ConversionRates(
      rates: conversionRates ?? this.rates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
