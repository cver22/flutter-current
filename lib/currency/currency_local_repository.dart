import '../env.dart';
import '../utils/db_consts.dart';
import 'package:hive/hive.dart';

import 'currency_models/conversion_rates.dart';

abstract class CurrencyLocalRepository {
  Future<Map<String, ConversionRates>> loadAllConversionRates({required String uid});

  Future<void> saveConversionRates({required Map<String, ConversionRates> conversionRateMap, required String uid});
}

class HiveCurrencyRepository extends CurrencyLocalRepository {
  @override
  Future<Map<String, ConversionRates>> loadAllConversionRates({required String uid}) async {
    print('Loading conversion rates from hive');
    var box = Hive.box(CURRENCY_BOX);

    Map<String, ConversionRates> conversionRateMap =
        Map<String, ConversionRates>.from(Env.store.state.currencyState.conversionRateMap);

    if (box.get('CONVERSION_RATE_MAP$uid') != null) {
      Map<String, ConversionRates> hiveConversionRateMap = box.get(CONVERSION_RATE_MAP).cast<String, ConversionRates>();

      if (hiveConversionRateMap.isNotEmpty) {
        conversionRateMap = hiveConversionRateMap;
      }
    }

    return conversionRateMap;
  }

  @override
  Future<void> saveConversionRates({required Map<String, ConversionRates> conversionRateMap, required String uid}) async {
    print('Saving refreshed conversion rates to hive');
    var box = Hive.box(CURRENCY_BOX);
    box.put('CONVERSION_RATE_MAP$uid', conversionRateMap);
  }
}
