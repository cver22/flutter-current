import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/currency/currency_utils/currency_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('currency formatter', () {
    test('formattedAmount no value', () {
      expect(formattedAmount(currency: CurrencyService().findByCode('USD')!), '');
    });

    test('formattedAmount 10.00', () {
      expect(formattedAmount(currency: CurrencyService().findByCode('USD')!, value: 1011), '10.11');
    });

    test(' formattedAmount 10.00', () {
      expect(formattedAmount(currency: CurrencyService().findByCode('USD')!, value: -1000), '-10.00');
    });

    test('formattedAmount \$ 10.00', () {
      expect(
          formattedAmount(currency: CurrencyService().findByCode('USD')!, value: 1040, showSymbol: true), '\$ 10.40');
    });

    test('formattedAmount USD \$ 10.00', () {
      expect(
          formattedAmount(
              currency: CurrencyService().findByCode('USD')!, value: 1000, showSymbol: true, showCode: true),
          'USD \$ 10.00');
    });

    test('formattedAmount USD flag \$ 10.00', () {
      Currency currency = CurrencyService().findByCode('USD')!;

      expect(formattedAmount(currency: currency, value: 1000, showSymbol: true, showCode: true, showFlag: true),
          'USD ${CurrencyUtils.currencyToEmoji(currency)} \$ 10.00');
    });

    test('formattedAmount 100,000.12', () {
      expect(formattedAmount(currency: CurrencyService().findByCode('USD')!, value: 10000012, showSeparators: true),
          '100,000.12');
    });

    test('formattedAmount 100000.12', () {
      expect(formattedAmount(currency: CurrencyService().findByCode('USD')!, value: 10000012), '100000.12');
    });

    test('formattedAmount EUR 100 200,40 €', () {
      expect(
          formattedAmount(
              currency: CurrencyService().findByCode('EUR')!,
              value: 10020040,
              showSymbol: true,
              showCode: true,
              showSeparators: true),
          'EUR 100 200,40 €');
    });

    test('formattedAmount EUR 100 200,40 €', () {
      expect(
          formattedAmount(
              currency: CurrencyService().findByCode('EUR')!, value: 10020040, showSymbol: true, showCode: true),
          'EUR 100200,40 €');
    });

    test('formattedAmount 0.00', () {
      expect(formattedAmount(currency: CurrencyService().findByCode('USD')!, showTrailingZeros: true), '0.00');
    });

    test('formattedAmount 0,00', () {
      expect(formattedAmount(currency: CurrencyService().findByCode('EUR')!, showTrailingZeros: true), '0,00');
    });
  });

  group('currency parser', () {
    test('parseNewValue -10', () {
      expect(parseNewValue(newValue: '-10', currency: CurrencyService().findByCode('USD')!), -1000);
    });

    test('parseNewValue 168', () {
      expect(parseNewValue(newValue: '168', currency: CurrencyService().findByCode('USD')!), 16800);
    });

    test('parseNewValue 43.50', () {
      expect(parseNewValue(newValue: '43.5', currency: CurrencyService().findByCode('USD')!), 4350);
    });

    test('parseNewValue 43.50', () {
      expect(parseNewValue(newValue: '43,5', currency: CurrencyService().findByCode('EUR')!), 4350);
    });

    test('parseNewValue 200023.50', () {
      expect(parseNewValue(newValue: '200023.50', currency: CurrencyService().findByCode('CAD')!), 20002350);
    });
  });
}
