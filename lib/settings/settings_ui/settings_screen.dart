import 'package:flutter/material.dart';

import '../../app/common_widgets/app_button.dart';
import '../../app/common_widgets/app_currency_picker.dart';
import '../../categories/categories_screens/category_button.dart';
import '../../categories/categories_screens/master_category_list_dialog.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../store/actions/settings_actions.dart';
import '../../store/app_store.dart';
import '../../store/connect_state.dart';
import '../../utils/db_consts.dart';
import '../../utils/maybe.dart';
import '../../utils/utils.dart';
import '../settings_model/settings_state.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConnectState<SettingsState>(
        where: notIdentical,
        map: (state) => state.settingsState,
        builder: (settingsState) {
          print('Rendering SettingsScreen');

          return Scaffold(
            appBar: AppBar(
              title: Text('Settings'),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Default Log:'),
                      SizedBox(width: 10),
                      _logNameDropDown(settingsState: settingsState),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('Default Currency:'),
                      SizedBox(width: 10),
                      AppCurrencyPicker(
                          currency: settingsState.settings.value.homeCurrency,
                          returnCurrency: (currency) => Env.store.dispatch(
                              SettingsUpdate(
                                  settings: Maybe.some(settingsState
                                      .settings.value
                                      .copyWith(homeCurrency: currency))))),
                    ],
                  ),
                  SizedBox(height: 10),
                  _categoryButton(
                      settingsState: settingsState, context: context),
                  SizedBox(
                    height: 50,
                  ),
                  AppButton(
                      //TODO convert to Get or not necessary?
                      child: Text('Reset All Settings'),
                      onPressed: () => {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Reset Settings'),
                                    content: Text(
                                        'Are you sure you want to reset all settings?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Yes'),
                                        onPressed: () {
                                          Env.settingsFetcher
                                              .readResetAppSettings(
                                                  resetSettings: true);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                })
                          }),
                  AppButton(
                    child: Text('Reload settings'),
                    onPressed: () {
                      Env.settingsFetcher
                          .readResetAppSettings(resetSettings: false);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _logNameDropDown({SettingsState settingsState}) {
    AppStore _store = Env.store;
    if (_store.state.logsState.logs.isNotEmpty) {
      Map<String, Log> _logsMap = _store.state.logsState.logs;
      List<Log> _logs = _logsMap.entries.map((e) => e.value).toList();

      String _defaultLogId = settingsState.settings.value.defaultLogId;

      //catches error if default log is null or is no longer active
      if (_defaultLogId == null || !_logsMap.containsKey(_defaultLogId)) {
        _defaultLogId = _logs.first.id;
        print(_defaultLogId);
      }

      return DropdownButton<Log>(
        value: _logs?.firstWhere((e) => e.id == _defaultLogId),
        onChanged: (Log log) {
          _defaultLogId = log.id;
          _store.dispatch(SettingsChangeDefaultLog(log: log));
        },
        items: _logs.map((Log log) {
          return DropdownMenuItem<Log>(
            value: log,
            child: Text(
              log.name,
              style: TextStyle(color: Colors.black),
            ),
          );
        }).toList(),
      );
    } else {
      return Container();
    }
  }

  Widget _categoryButton({SettingsState settingsState, BuildContext context}) {
    return CategoryButton(
      label: 'Edit Default Categories',
      onPressed: () => {
        /*Get.dialog(CategoryListDialog()),*/
        showDialog(
          context: context,
          builder: (_) {
            Env.store.dispatch(SettingsSetExpandedCategories());
            return MasterCategoryListDialog(
                setLogFilter: SettingsLogFilter.settings);
          },
        ),
      },
      category: null, // do not pass a category, maintains label
    );
  }
}
