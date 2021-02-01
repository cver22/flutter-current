import 'package:expenses/app/common_widgets/exit_confirmation_dialog.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/master_category_list_dialog.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/member/member_ui/log_member_simple_ui/log_member_total_list.dart';
import 'package:expenses/qr_reader/qr_ui/qr_reader.dart';
import 'package:expenses/settings/settings_model/settings.dart';
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

  Future<bool> _confirmationDialog() async {
    bool onWillPop = false;
    await Get.dialog(
      ExitConfirmationDialog(
        title: 'Exit without saving?',
        pop: (willPop) => {onWillPop = willPop},
        onTap: () => {
          Env.store.dispatch(ClearSelectedLog()),
        },
      ),
    );

    if (onWillPop) Get.back(); //used for back arrow

    return onWillPop; //used for willPop
  }

  @override
  Widget build(BuildContext context) {
    Log log;
    String currency;
    String name;
    return ConnectState<LogsState>(
      where: notIdentical,
      map: (state) => state.logsState,
      builder: (logsState) {


        if (logsState.selectedLog.isNone) {
          return Container();
        }

        log = logsState.selectedLog.value;
        currency = log?.currency; //TODO change to home currency as default
        name = log?.name ?? null;

        return WillPopScope(
          onWillPop: () async {

            return _confirmationDialog();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Log'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _confirmationDialog(),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: canSave(name) ? Colors.white : Colors.grey,
                  ),
                  onPressed: canSave(name) ? () => _submit() : null,
                ),
                log.id == null
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
            body: _buildContents(context: context, log: log, currency: currency, logs: logsState.logs),
          ),
        );
      },
    );
  }

  bool canSave(String name) => name != null && name != '';

  Widget _buildContents(
      {@required BuildContext context, @required Log log, @required String currency, @required Map<String, Log> logs}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildLogNameForm(log: log),
                SizedBox(height: 16.0),

                log.uid == null ? NewLogCategorySource(logs: logs, log: log) : Container(),
                SizedBox(height: 16.0),
                log.uid == null ? Container() : _categoryButton(context: context, log: log),
                //log.uid == null ? Container() : _subcategoryButton(context: context, log: log),
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

  Widget _buildLogNameForm({@required Log log}) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Log Title'),
      initialValue: log.name,
      onChanged: (name) => Env.store.dispatch(UpdateSelectedLog(log: log.copyWith(name: name))),
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
                builder: (_) => MasterCategoryListDialog(
                  setLogEnt: SettingsLogEntry.log,
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

class NewLogCategorySource extends StatefulWidget {
  const NewLogCategorySource({
    Key key,
    @required this.logs,
    @required this.log,
  }) : super(key: key);

  final Map<String, Log> logs;
  final Log log;

  @override
  _NewLogCategorySourceState createState() => _NewLogCategorySourceState();
}

class _NewLogCategorySourceState extends State<NewLogCategorySource> {
  Log defaultLog;
  Log currentDropDownSelection;
  List<Log> temporaryLogs = [];

  @override
  void initState() {
    super.initState();
    //converts the settings to a temporary log for the purpose of creating a drop down list
    //from this list, the user can decide where they are getting the category list from
    Settings settings = Env.store.state.settingsState.settings.value;
    defaultLog = Log(
        name: 'Default',
        id: 'default',
        categories: settings.defaultCategories,
        subcategories: settings.defaultSubcategories);
    temporaryLogs = widget.logs.entries.map((e) => e.value).toList();
    temporaryLogs.insert(0, defaultLog);
    Env.store.dispatch(NewLogSetCategories(log: defaultLog));
    currentDropDownSelection = defaultLog;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text('Copy Categories From:  '),
        DropdownButton<Log>(
          //TODO order preference logs and set default to first log if not navigating from the log itself
          value: currentDropDownSelection,
          onChanged: (Log log) {
            Env.store.dispatch(NewLogSetCategories(log: log));
          },
          items: temporaryLogs.map((Log log) {
            return DropdownMenuItem<Log>(
              value: log,
              child: Text(
                log.name,
                style: TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
