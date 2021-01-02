import 'package:meta/meta.dart';

String formattedAmount({@required int value, bool withSeparator = false}) {
  bool isNegative = false;
  int absValue = value?.abs();
  int smallUnits = 0;
  int bigUnits = 0;
  String bigUnitsString = '';

  if (absValue != null && absValue > 99) {
    bigUnits = (absValue / 100).truncate();
    smallUnits = absValue.remainder(100);
  } else if (absValue != null && absValue > 0) {
    smallUnits = absValue;
  }

  if (value != null && value < 0) {
    isNegative = !isNegative;
  }

  if (bigUnits == 0 && smallUnits == 0) {
    return '';
  }

  //Adds separator to the string if big units is greater than 3
  if (withSeparator && bigUnits.toString().length > 3) {
    String oldString = bigUnits.toString();
    int i = bigUnits.toString().length;
    bigUnitsString = oldString.substring(i - 3, i);
    oldString = oldString.substring(0, i - 3);
    i -= 3;

    while (i > 0) {
      int j = i - 3 < 0 ? 0 : i - 3;
      bigUnitsString = '${oldString.substring(j, i)},$bigUnitsString';
      i = j;
      print(bigUnitsString);
    }
  } else {
    bigUnitsString = bigUnits.toString();
  }

  return '${isNegative ? '-' : ''}$bigUnitsString.${smallUnits.toString().padLeft(2, '0')}';
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
