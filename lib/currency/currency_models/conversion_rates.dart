import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class ConversionRates extends Equatable {
  final Map<String, double> conversionRates; // Currency to convert from to log currency and rate
  final DateTime lastUpdated;

  ConversionRates({
    this.conversionRates = const {},
    @required this.lastUpdated,
  });

  @override
  List<Object> get props => [conversionRates, lastUpdated];

  @override
  bool get stringify => true;

  ConversionRates copyWith({
    Map<String, double> conversionRates,
    DateTime lastUpdated,
  }) {
    if ((conversionRates == null || identical(conversionRates, this.conversionRates)) &&
        (lastUpdated == null || identical(lastUpdated, this.lastUpdated))) {
      return this;
    }

    return new ConversionRates(
      conversionRates: conversionRates ?? this.conversionRates,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
