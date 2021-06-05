import 'dart:convert';
import 'package:currency_picker/src/currency.dart';
import 'package:expenses/currency/currency_models/conversion_rates.dart';
import 'package:http/http.dart' as http;

abstract class CurrencyRemoteRepository {
  Future<ConversionRates> loadReferenceConversionRates(
      {required String referenceCurrency, required List<Currency> allCurrencies});
}

class ExchangeRatesApiRepository extends CurrencyRemoteRepository {
  @override
  Future<ConversionRates> loadReferenceConversionRates(
      {required String referenceCurrency, required List<Currency> allCurrencies}) async {
    String uri = "https://v6.exchangerate-api.com/v6/410045c4325703c06f39ff30/latest/$referenceCurrency";
    var response = await http.get(Uri.parse(uri), headers: {'Accept': 'application/json'});
    Map<String, dynamic>? responseBody = json.decode(response.body);

    //TODO error handling

    return mapConversionRates(referenceCurrency: referenceCurrency, allCurrencies: allCurrencies, json: responseBody);
  }
}

ConversionRates mapConversionRates(
    {required String referenceCurrency, required List<Currency> allCurrencies, Map<String, dynamic>? json}) {
  Map<String, double> rates = Map<String, double>();
  DateTime? dateUpdated;

  allCurrencies.forEach((currency) {
    double conversionRate = 0.0;
    if (json != null) {
      var jsonConversionRate = json['conversion_rates'][currency.code];

      //error checking to prevent attempting to convert null return from json for a particular currency
      if (jsonConversionRate != null) {
        conversionRate = jsonConversionRate.toDouble();
      }
    }
    rates.update(currency.code, (value) => conversionRate, ifAbsent: () => conversionRate);
  });

  if (json != null) {
    dateUpdated = DateTime.fromMillisecondsSinceEpoch(json['time_last_update_unix'].toInt() * 1000);
  }
  return ConversionRates(lastUpdated: dateUpdated, rates: rates);
}
