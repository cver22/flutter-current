import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'conversion_rates.dart';

part 'currency_hive.g.dart';

//type id can never be changed
@HiveType(typeId: 1)
class CurrencyHive extends Equatable {
  //field ids can only be dropped, not changed
  @HiveField(0)
  Map<String, ConversionRates> conversionRateMap;

  CurrencyHive({
    required this.conversionRateMap,
  });

  @override
  List<Object?> get props => [conversionRateMap];
}
