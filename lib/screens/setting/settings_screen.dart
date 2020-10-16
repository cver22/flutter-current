import 'package:expenses/env.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/models/settings/settings_state.dart';
import 'package:expenses/screens/categories/category_button.dart';
import 'package:expenses/screens/categories/new_category_list_dialog.dart';
import 'package:expenses/screens/common_widgets/my_currency_picker.dart';
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
                  _logNameDropDown(settingsState: settingsState),
                  MyCurrencyPicker(
                      currency: settingsState.settings.value.homeCurrency,
                      returnCurrency: (currency) => Env.store.dispatch(UpdateSettings(
                          settings: Maybe.some(settingsState.settings.value.copyWith(homeCurrency: currency))))),
                  _categoryButton(settingsState: settingsState, context: context),
                  _subcategoryButton(settingsState: settingsState, context: context),
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

      if (_defaultLogId == null && !_logsMap.containsKey(_defaultLogId)) {
        _defaultLogId = _logs.first.id;
      }

      return DropdownButton<Log>(
        value: _logs.firstWhere((e) => e.id == _defaultLogId),
        onChanged: (Log log) {
          _defaultLogId = log.id;
          _store.dispatch(
              UpdateSettings(settings: Maybe.some(settingsState.settings.value.copyWith(defaultLogId: _defaultLogId))));
        },
        items: _logs.map((Log log) {
          return DropdownMenuItem<Log>(
            value: log,
            child: Text(
              log.logName,
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
                builder: (_) => NewCategoryListDialog(
                  categoryOrSubcategory: CategoryOrSubcategory.category,
                ),
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
                builder: (_) => NewCategoryListDialog(
                  categoryOrSubcategory: CategoryOrSubcategory.subcategory,
                ),
              ),
            },
            category: null, // do not pass a category, maintains label
          );
  }
}
