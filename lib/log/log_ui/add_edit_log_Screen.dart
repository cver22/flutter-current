import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/category_list_dialog.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/member/member_ui/log_member_simple_ui/log_member_total_list.dart';
import 'package:expenses/qr_reader/qr_ui/qr_reader.dart';
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
    Env.store.dispatch(AddUpdateLog());

    Get.back();
  }

  void closeAddEditLogScreen() {
    Get.back();
    Env.store.dispatch(ClearSelectedLog());
  }

  @override
  Widget build(BuildContext context) {
    Log _log = Log(currency: 'CAD');
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
        _name = _log?.name ?? null;
        return WillPopScope(
          onWillPop: () async {
            Get.back();
          return true;
        },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Log'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => closeAddEditLogScreen(),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: canSave(_name) ? Colors.white : Colors.grey,
                  ),
                  onPressed: canSave(_name) ? () => _submit() : null,
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
          ),
        );
      },
    );
  }

  bool canSave(String _name) => _name != null && _name != '';

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
                _buildLogMemberList(log: log),
                _buildAddMemberButton(log: log),
                SizedBox(height: 16.0),
                //_buildMakeDefaultButton(log: log),
                SizedBox(height: 16.0),
                _buildCurrencyPicker(log: log, currency: currency),
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
      initialValue: log.name,
      onChanged: (value) => Env.store.dispatch(UpdateSelectedLog(log: log.copyWith(name: value))),
      //TODO validate name cannot be empty
      //TODO need controllers
    );
  }

  void handleClick(String value) {
    //TODO, I don't like how this works, I would prefer to just pass the log to it
    switch (value) {
      case 'Delete Log':
        Env.store.dispatch(DeleteLog(log: Env.store.state.logsState.selectedLog.value));
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

  Widget _buildLogMemberList({@required Log log}) {
    return log.uid == null ? Container() : LogMemberTotalList(log: log);
  }

  Widget _buildAddMemberButton({@required Log log}) {
    return log.uid == null
        ? Container()
        : RaisedButton(
            elevation: RAISED_BUTTON_ELEVATION,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
            child: Text('Add new log member'),
            onPressed: () {
              Get.to(QRReader());
            },
          );
  }


  //TODO need to react to change in settings for this widget to rebuild, or make it a stateful widget
  /*Widget _buildMakeDefaultButton({@required Log log}) {
    if (log?.id == null) {
      return Container();
    }

    bool isDefault = log.id == Env.store.state.settingsState.settings.value.defaultLogId ? true : false;

    return RaisedButton(
      elevation: RAISED_BUTTON_ELEVATION,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RAISED_BUTTON_CIRCULAR_RADIUS)),
      child: Text(
        isDefault ? 'Default Log' : 'Make Log Default',
        //style: TextStyle(color: isDefault ? Colors.grey : Colors.black),
      ),
      onPressed: isDefault
          ? null
          : () {
              Env.store.dispatch(ChangeDefaultLog(log: log));
            },
    );
  }*/

  Widget _buildCurrencyPicker({@required Log log, @required String currency}) {
    return log.uid == null
        ? MyCurrencyPicker(
            currency: currency,
            returnCurrency: (currency) => Env.store.dispatch(UpdateSelectedLog(log: log.copyWith(currency: currency))))
        : Text('Currency: $currency');
  }
}
