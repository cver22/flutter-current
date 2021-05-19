import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/app/common_widgets/list_tile_components.dart';
import 'package:flutter/material.dart';

class CurrencyListTile extends StatelessWidget {
  final Currency currency;
  final double? conversionRate;
  final Currency? referenceCurrency;
  final Function(String) onTap;
  final bool withConversionRates;
  final Widget? trailingCheckBox;

  const CurrencyListTile({
    Key? key,
    required this.currency,
    this.conversionRate,
    this.referenceCurrency,
    required this.onTap,
    this.withConversionRates = false,
    this.trailingCheckBox,
  }) : super(key: key);

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
              onTap(currency.code);
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
                              if (withConversionRates &&
                                  conversionRate != null &&
                                  referenceCurrency != null &&
                                  currency.code != referenceCurrency!.code &&
                                  conversionRate != 0)
                                Text(
                                  '1 ${CurrencyUtils.currencyToEmoji(currency)} => ${conversionRate!.toStringAsFixed(5)} ${CurrencyUtils.currencyToEmoji(referenceCurrency)}',
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
                    child: trailingCheckBox ??
                        Text(
                          currency.symbol,
                          style: const TextStyle(fontSize: 18),
                        ),
                  ),
                ],
              ),
            ),
          ),
          AppDivider(),
        ],
      ),
    );
  }
}
