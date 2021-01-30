import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/category_list_dialog.dart';
import 'package:expenses/categories/categories_screens/master_category_list_dialog.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

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
                      MyCurrencyPicker(
                          currency: settingsState.settings.value.homeCurrency,
                          returnCurrency: (currency) => Env.store.dispatch(UpdateSettings(
                              settings: Maybe.some(settingsState.settings.value.copyWith(homeCurrency: currency))))),
                    ],
                  ),
                  SizedBox(height: 10),
                  _categoryButton(settingsState: settingsState, context: context),
                  SizedBox(
                    height: 50,
                  ),
                  RaisedButton(
                      //TODO convert to Get or not necessary?
                      child: Text('Reset All Settings'),
                      onPressed: () => {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Reset Settings'),
                                    content: Text('Are you sure you want to reset all settings?'),
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
                                          Env.settingsFetcher.readResetAppSettings(resetSettings: true);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                })
                          }),
                  RaisedButton(child: Text('Reload settings'),
                  onPressed: () {
                    Env.settingsFetcher.readResetAppSettings(resetSettings: false);
                  },),
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
          _store.dispatch(
            ChangeDefaultLog(log: log));

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
    return settingsState?.settings?.value?.defaultCategories == null
        ? Container()
        : CategoryButton(
            label: 'Edit Default Categories',
            onPressed: () => {
              /*Get.dialog(CategoryListDialog()),*/
              showDialog(
                context: context,
                builder: (_) => MasterCategoryListDialog(setLogEnt: SettingsLogEntry.settings,),
              ),
            },
            category: null, // do not pass a category, maintains label
          );
  }

  Widget _subcategoryButton({SettingsState settingsState, BuildContext context}) {
    return settingsState?.settings?.value?.defaultSubcategories == null
        ? Container()
        : CategoryButton(
            label: 'Edit Default Subcategories',
            onPressed: () => {
              /*Get.dialog(
                SubcategoryListDialog(
                  backChevron: () => Navigator.of(context).pop(),
                ),
              )*/
              showDialog(
                context: context,
                builder: (_) => CategoryListDialog(
                  settingsLogEntry: SettingsLogEntry.settings,
                  categoryOrSubcategory: CategoryOrSubcategory.subcategory,
                ),
              ),
            },
            category: null, // do not pass a category, maintains label
          );
  }
}
