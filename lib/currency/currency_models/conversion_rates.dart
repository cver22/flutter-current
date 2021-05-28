import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'conversion_rates.g.dart';

@immutable
//type id can never be changed
@HiveType(typeId: 2)
class ConversionRates extends Equatable{
  //field ids can only be dropped, not changed
  @HiveField(0)
  final Map<String, double> rates; // Currency to convert from to log currency and rate
  @HiveField(1)
  final DateTime? lastUpdated;

  ConversionRates({
    this.rates = const <String, double>{},
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [rates, lastUpdated];

  @override
  bool get stringify => true;

  ConversionRates copyWith({
    Map<String, double>? conversionRates,
    DateTime? lastUpdated,
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
