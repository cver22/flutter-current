import 'package:currency_picker/currency_picker.dart';
import 'package:meta/meta.dart';
import '../../app/models/app_state.dart';
import 'app_actions.dart';

class CurrencyInitializeCurrencies implements AppAction {
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith()),
      ],
    );
  }
}

class CurrencySearchCurrencies implements AppAction {
  final String search;

  CurrencySearchCurrencies({@required this.search});

  AppState updateState(AppState appState) {
    List<Currency> searchCurrencies = <Currency>[];

    if (search.isNotEmpty) {
      searchCurrencies = List<Currency>.from(appState.currencyState.allCurrencies)
        ..retainWhere((element) =>
            element.name.toLowerCase().contains(search.toLowerCase()) ||
            element.code.toLowerCase().contains(search.toLowerCase()));
    }

    return updateSubstates(
      appState,
      [
        updateCurrencyState((currencyState) => currencyState.copyWith(searchCurrencies: searchCurrencies)),
      ],
    );
  }
}
