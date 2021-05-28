import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class CurrencyRemoteRepository {
  Future<Map<String, dynamic>?> loadReferenceConversionRates({required String referenceCurrency});
}

class ExchangeRatesApiRepository extends CurrencyRemoteRepository {

  @override
  Future<Map<String, dynamic>?> loadReferenceConversionRates({String? referenceCurrency}) async {
    String uri = "https://v6.exchangerate-api.com/v6/410045c4325703c06f39ff30/latest/$referenceCurrency";
    var response = await http.get(Uri.parse(uri), headers: {'Accept': 'application/json'});
    Map<String, dynamic>? responseBody = json.decode(response.body);

    //TODO error handling

    return responseBody;
  }
}
