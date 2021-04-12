import 'package:currency_picker/currency_picker.dart';
import 'package:currency_picker/src/currency.dart';
import 'package:meta/meta.dart';

String formattedAmount(
    {int value = 0,
    bool showSeparators = false,
    bool showTrailingZeros = false,
    Currency currency,
    bool showSymbol = false,
    bool showCurrency = false}) {
  String returnString = '';

  if (value != 0) {
    bool isNegative = value < 0;
    int absValue = value.abs();
    int smallUnits = 0;
    int bigUnits = 0;
    String bigUnitsString = '';

    //extract small digits if currency has decimal places
    if (currency.decimalDigits > 0) {
      if (absValue > 99) {
        bigUnits = (absValue / 100).truncate();
        smallUnits = absValue.remainder(100);
      } else if (absValue > 0) {
        smallUnits = absValue;
      }
    } else {
      bigUnits = absValue;
    }

    //Adds separator to the string if big units is greater than 3
    if (showSeparators && bigUnits.toString().length > 3) {
      String oldString = bigUnits.toString();
      int i = bigUnits.toString().length;
      bigUnitsString = oldString.substring(i - 3, i);
      oldString = oldString.substring(0, i - 3);
      i -= 3;

      while (i > 0) {
        int j = i - 3 < 0 ? 0 : i - 3;
        bigUnitsString = '${oldString.substring(j, i)}${currency.thousandsSeparator}$bigUnitsString';
        i = j;
      }
    } else {
      bigUnitsString = bigUnits.toString();
    }

    if (isNegative) {
      returnString = '-';
    }

    returnString += bigUnitsString;

    if (currency.decimalDigits > 0) {
      returnString += '${currency.decimalSeparator}${smallUnits.toString().padLeft(2, '0')}';
    }
  } else {
    returnString = showTrailingZeros ? '0.00' : returnString;
  }

  if (showSymbol && currency.symbolOnLeft) {
    returnString = '${currency.symbol} $returnString';
  } else if (showSymbol && !currency.symbolOnLeft) {
    returnString = '$returnString ${currency.symbol}';
  }

  if (showCurrency) {
    returnString = '${currency.code} $returnString';
  }

  return returnString;
}

int parseNewValue({@required String newValue, @required Currency currency}) {
  bool isNegative = false;
  String absoluteString = newValue;
  int value = 0;

  if (absoluteString != null && absoluteString.length > 0) {
    if (absoluteString.startsWith('\-')) {
      isNegative = !isNegative;
      absoluteString = absoluteString.substring(1);

      if (absoluteString.length == 0) {
        return 0;
      }
    }

    if (currency.decimalDigits > 0 && absoluteString.contains('.')) {
      value = _parseBigAndSmallUnits(value, absoluteString.indexOf('.'), absoluteString);
    } else if (currency.decimalDigits > 0 && absoluteString.contains(',')) {
      value = _parseBigAndSmallUnits(value, absoluteString.indexOf(','), absoluteString);
    } else if (currency.decimalDigits > 0) {
      value = (int.parse(absoluteString)) * 100;
    } else {
      value = int.parse(absoluteString);
    }
  }

  return isNegative ? -value : value;
}

int _parseBigAndSmallUnits(int value, int decimalIndex, String absoluteString) {
  value = decimalIndex > 0 ? (int.parse(absoluteString.substring(0, decimalIndex))) * 100 : 0;
  String smallUnitsString = absoluteString.substring(decimalIndex + 1);
  int smallUnitsInt = smallUnitsString.length < 2 ? int.parse('${smallUnitsString}0') : int.parse(smallUnitsString);

  value = value + smallUnitsInt; //adds trailing zero if the last digit has not been added
  return value;
}
