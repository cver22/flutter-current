import 'package:meta/meta.dart';

String formattedAmount({@required int value}) {
  bool isNegative = false;
  int absValue = value?.abs();
  int smallUnits = 0;
  int bigUnits = 0;
  String stringAmount = '';

  if (absValue != null && absValue > 99) {
    bigUnits = (absValue / 100).truncate();
    smallUnits = absValue.remainder(100);
  } else if (absValue != null && absValue > 0) {
    smallUnits = absValue;
  }

  if (value != null && value < 0) {
    isNegative = !isNegative;
  }
  print('the value is $value, bigUnits $bigUnits and smallUnits $smallUnits');

  return '${isNegative ? '-' : ''}$bigUnits.${smallUnits.toString().padLeft(2, '0')}';
}

int parseNewValue({@required String newValue}) {
  bool isNegative = false;
  String absoluteString = newValue;
  int value = 0;

  if (absoluteString != null && absoluteString.length > 0) {
    if (absoluteString.startsWith('\-')) {
      isNegative = !isNegative;
      absoluteString = absoluteString.substring(1);
    }
    print('absoluteString $absoluteString');

    if (absoluteString.contains('\.')) {
      int decimalIndex = absoluteString.indexOf('\.');
      value = (int.parse(absoluteString.substring(0, decimalIndex))) * 100;
      String smallUnitsString = absoluteString.substring(decimalIndex + 1);
      int smallUnitsInt = smallUnitsString.length < 2 ? int.parse('${smallUnitsString}0') : int.parse(smallUnitsString);

      print('small units $smallUnitsInt');

      value = value + smallUnitsInt; //adds trailing zero if the last digit has not been added
    } else {
      value = (int.parse(absoluteString)) * 100;
    }
  }

  return isNegative ? -value : value;
}
