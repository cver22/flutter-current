import 'package:currency_picker/currency_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CurrencyListTile extends StatelessWidget {
  final Currency currency;
  final double conversionRate;
  final Currency baseCurrency;
  final Function(String) returnCurrency;
  final bool withConversionRates;

  const CurrencyListTile(
      {Key? key, required this.currency, this.conversionRate = 0.0, required this.baseCurrency, required this.returnCurrency, this.withConversionRates = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      // Add Material Widget with transparent color
      // so the ripple effect of InkWell will show on tap
      color: Colors.transparent,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              returnCurrency(currency.code);
              Get.back();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Text(
                          CurrencyUtils.currencyToEmoji(currency),
                          style: const TextStyle(fontSize: 25),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.code,
                                style: const TextStyle(fontSize: 17),
                              ),
                              Text(
                                currency.name,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              if (withConversionRates && currency.code != baseCurrency.code && conversionRate != 0)
                                Text(
                                  '1 ${CurrencyUtils.currencyToEmoji(currency)} => ${conversionRate.toPrecision(5)} ${CurrencyUtils.currencyToEmoji(baseCurrency)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      currency.symbol,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 0.0),
        ],
      ),
    );
  }
}
