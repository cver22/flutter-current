import 'package:currency_picker/currency_picker.dart';
import 'package:get/get.dart';
import '../../utils/db_consts.dart';
import 'package:flutter/material.dart';

class CurrencyListTile extends StatelessWidget {
  final Currency currency;
  final double conversionRate;
  final Currency logCurrency;
  final Function(String) returnCurrency;

  const CurrencyListTile({Key key, @required this.currency, this.conversionRate = 0.00, @required this.logCurrency, @required this.returnCurrency}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Text(
            CurrencyUtils.countryCodeToEmoji(currency),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: EMOJI_SIZE),
          ),
          title: Transform.translate(
            offset: Offset(-16, 0),
            child: Text(currency.code),
          ),
          subtitle: Transform.translate(
            offset: Offset(-16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currency.name),
                if (conversionRate != null && currency.code != logCurrency.code) Text('1 ${CurrencyUtils.countryCodeToEmoji(currency)} => ${conversionRate.toPrecision(5)} ${CurrencyUtils.countryCodeToEmoji(logCurrency)}'),
              ],
            ),
          ),
          trailing: Text(currency.symbol),
          onTap: () {
            returnCurrency(currency.code);
            Get.back();
          },
        ),
        Divider(height: 0.0),
      ],
    );
  }
}
