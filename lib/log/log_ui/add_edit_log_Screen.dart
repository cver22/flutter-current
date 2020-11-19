import 'package:currency_pickers/utils/utils.dart';
import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/category_list_dialog.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditLogScreen extends StatelessWidget {
  const AddEditLogScreen({Key key}) : super(key: key);

  void _submit() {
    print('submit pressed');
    Log log = Env.store.state.logsState.selectedLog.value;

    if (log.id != null) {
      Env.logsFetcher.updateLog(log);
    } else {
      Env.logsFetcher.addLog(log);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    Log _log = Log(currency: 'ca');
    String _currency;
    String _name;
    return ConnectState<LogsState>(
      where: notIdentical,
      map: (state) => state.logsState,
      builder: (logsState) {
        if (logsState.selectedLog.isSome) {
          _log = logsState.selectedLog.value;
        }
        _currency = _log?.currency; //TODO change to home currency as default
        _name = _log?.logName ?? null;
        return Scaffold(
          appBar: AppBar(
            title: Text('Log'),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_name != null && _name != '') _submit();
                },
              ),
              _log.id == null
                  ? Container()
                  : PopupMenuButton<String>(
                      onSelected: handleClick,
                      itemBuilder: (BuildContext context) {
                        return {'Delete Log'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
            ],
          ),
          body: _buildContents(context: context, log: _log, currency: _currency),
        );
      },
    );
  }

  Widget _buildContents({@required BuildContext context, @required Log log, @required String currency}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildForm(log: log),
                SizedBox(height: 16.0),
                log.uid == null ? Container() : _categoryButton(context: context, log: log),
                log.uid == null ? Container() : _subcategoryButton(context: context, log: log),
                SizedBox(height: 16.0),
                log.uid == null
                    ? MyCurrencyPicker(
                        currency: currency,
                        returnCurrency: (currency) =>
                            Env.store.dispatch(UpdateSelectedLog(log: log.copyWith(currency: currency))))
                    : Text('Currency: ${CurrencyPickerUtils.getCountryByIsoCode(currency).currencyCode}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm({@required Log log}) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Log Title'),
      initialValue: log.logName,
      onChanged: (value) => Env.store.dispatch(UpdateSelectedLog(log: log.copyWith(logName: value))),
      //TODO validate name cannot be empty
      //TODO need controllers
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Delete Log':
        Env.logsFetcher.deleteLog(Env.store.state.logsState.selectedLog.value);
        Get.back();
        break;
    }
  }

  Widget _categoryButton({@required BuildContext context, @required Log log}) {
    return log.categories == null
        ? Container()
        : CategoryButton(
            label: 'Edit Log Categories',
            onPressed: () => {
              /*Get.dialog(CategoryListDialog()),*/
              showDialog(
                context: context,
                builder: (_) => CategoryListDialog(
                  log: log,
                  settingsLogEntry: SettingsLogEntry.log,
                  categoryOrSubcategory: CategoryOrSubcategory.category,
                ),
              ),
            },
            category: null, // do not pass a category, maintains label
          );
  }

  Widget _subcategoryButton({@required BuildContext context, @required Log log}) {
    return log.subcategories == null
        ? Container()
        : CategoryButton(
            label: 'Edit Log Subcategories',
            onPressed: () => {
              /*Get.dialog(
                SubcategoryListDialog(
                  backChevron: () => Navigator.of(context).pop(),
                ),
              )*/
              showDialog(
                context: context,
                builder: (_) => CategoryListDialog(
                  log: log,
                  settingsLogEntry: SettingsLogEntry.log,
                  categoryOrSubcategory: CategoryOrSubcategory.subcategory,
                ),
              ),
            },
            category: null, // do not pass a category, maintains label
          );
  }
}
