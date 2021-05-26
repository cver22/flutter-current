
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../currency/currency_utils/currency_formatters.dart';
import '../../app/common_widgets/app_button.dart';
import '../../currency/currency_ui/app_currency_picker.dart';
import '../../app/common_widgets/simple_confirmation_dialog.dart';
import '../../categories/categories_screens/category_button.dart';
import '../../categories/categories_screens/master_category_list_dialog.dart';
import '../../env.dart';
import '../../member/member_ui/log_member_simple_ui/log_member_total_list.dart';
import '../../qr_reader/qr_ui/qr_reader.dart';
import '../../settings/settings_model/settings.dart';
import '../../store/actions/logs_actions.dart';
import '../../store/connect_state.dart';
import '../../utils/db_consts.dart';
import '../../utils/utils.dart';
import '../log_model/log.dart';
import '../log_model/logs_state.dart';
import 'log_name_form.dart';

class AddEditLogScreen extends StatelessWidget {
  const AddEditLogScreen({Key? key}) : super(key: key);

  void _submit() {
    print('submit pressed');
    Env.store.dispatch(LogAddUpdate());
    Get.back();
  }

  Future<bool> _exitConfirmationDialog({required bool canSave}) async {
    bool onWillPop = false;
    if (Env.store.state.logsState.userUpdated) {
      //user has made changes, confirm they wish to exit
      await Get.dialog(
        SimpleConfirmationDialog(
          title: canSave ? 'Save changes?' : 'Discard changes?',
          onTapDiscard: (pop) {
            onWillPop = pop;
          },
          confirmText: canSave ? 'Save' : null,
          canConfirm: canSave,
          onTapConfirm: (pop) {
            onWillPop = pop;
            if (canSave) _submit();
          },
        ),
      );
    } else {
      onWillPop = true;
    }

    if (onWillPop) {
      //close without saving
      Env.store.dispatch(LogClearSelected());
      Get.back();
    }

    return onWillPop;
  }

  Future<void> _deleteConfirmationDialog() async {
    bool deleteConfirmed = false;
    await Get.dialog(
      SimpleConfirmationDialog(
        title: 'Are you sure you want to delete this log?',
        content:
            'You will also lose all entries, tags and categories associated with this log. This CANNOT be undone! ',
        onTapConfirm: (delete) {
          deleteConfirmed = delete;
        },
      ),
    );

    if (deleteConfirmed) {
      await Get.dialog(
        SimpleConfirmationDialog(
          title: 'Please confirm you wish to delete this log?',
          onTapConfirm: (delete) {
            deleteConfirmed = delete;
            if (deleteConfirmed) {
              Env.store.dispatch(DeleteLog(log: Env.store.state.logsState.selectedLog.value));
              Get.back();
            }
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Log log;
    String? currency;
    bool canSave = false;
    return ConnectState<LogsState>(
      where: notIdentical,
      map: (state) => state.logsState,
      builder: (logsState) {
        if (logsState.selectedLog.isNone) {
          return Container();
        }

        log = logsState.selectedLog.value;
        currency = log.currency; //TODO change to home currency as default
        canSave = logsState.canSave;

        return WillPopScope(
          onWillPop: () async {
            return _exitConfirmationDialog(canSave: canSave);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Log'),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => _exitConfirmationDialog(canSave: canSave),
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.check,
                    color: canSave ? Colors.white : Colors.grey,
                  ),
                  onPressed: canSave ? () => _submit() : null,
                ),
                log.id != null
                    ? PopupMenuButton<String>(
                        onSelected: handleClick,
                        itemBuilder: (BuildContext context) {
                          return {'Delete Log'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      )
                    : Container(),
              ],
            ),
            body: _buildContents(context: context, log: log, currency: currency, logs: logsState.logs),
          ),
        );
      },
    );
  }

  Widget _buildContents(
      {required BuildContext context, required Log log, required String? currency, required Map<String, Log> logs}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                LogNameForm(log: log),
                if (log.id == null) SizedBox(height: 16.0),
                if (log.id == null) NewLogCategorySourceWidget(logs: logs, log: log),
                SizedBox(height: 16.0),
                if (log.id != null) _categoryButton(context: context, log: log),
                if (log.id != null) SizedBox(height: 16.0),
                if (log.id != null) _buildLogMemberList(log: log),
                if (log.id != null) SizedBox(height: 8.0),
                if (log.id != null) _buildAddMemberButton(log: log),
                if (log.id != null) SizedBox(height: 16.0),
                //_buildMakeDefaultButton(log: log),
                if (log.id != null) SizedBox(height: 16.0),
                _buildCurrencyPicker(log: log, currency: currency),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void handleClick(String value) {
    //TODO, I don't like how this works, I would prefer to just pass the log to it
    switch (value) {
      case 'Delete Log':
        _deleteConfirmationDialog();
        break;
    }
  }

  Widget _categoryButton({required BuildContext context, required Log log}) {
    return CategoryButton(
            label: 'Edit Log Categories',
            onPressed: () => {
              showDialog(
                context: context,
                builder: (_) => MasterCategoryListDialog(
                  setLogFilter: SettingsLogFilterEntry.log,
                ),
              ),
            },
            category: null, // do not pass a category, maintains label
          );
  }

  Widget _buildLogMemberList({required Log log}) {
    return LogMemberTotalList(log: log);
  }

  Widget _buildAddMemberButton({required Log log}) {
    return AppButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add new log member'),
                SizedBox(width: 16.0),
                Icon(Icons.camera_alt_outlined),
              ],
            ),
            onPressed: () {
              Get.to(QRReader());
            },
    );
  }

  //TODO need to react to change in settings for this widget to rebuild, or make it a stateful widget

  Widget _buildCurrencyPicker({required Log log, required String? currency}) {
    if (currency == null) {
      currency = Env.store.state.settingsState.settings.value.homeCurrency;
    }

    return log.id != null
        ? Text(currencyLabelFromCode(currencyCode: currency))
        : AppCurrencyPicker(
            title: 'Log Currency',
            buttonLabel: currencyLabelFromCode(currencyCode: currency), //TODO need to pull this from settings
            returnCurrency: (currency) {
              Env.store.dispatch(UpdateSelectedLog(log: log.copyWith(currency: currency)));
              Get.back();
            });
  }
}

class NewLogCategorySourceWidget extends StatefulWidget {
  const NewLogCategorySourceWidget({
    Key? key,
    required this.logs,
    required this.log,
  }) : super(key: key);

  final Map<String, Log> logs;
  final Log log;

  @override
  _NewLogCategorySourceWidgetState createState() => _NewLogCategorySourceWidgetState();
}

class _NewLogCategorySourceWidgetState extends State<NewLogCategorySourceWidget> {
  Log? defaultLog;
  Log? currentDropDownSelection;
  List<Log?> temporaryLogs = [];

  @override
  void initState() {
    super.initState();
    //converts the settings to a temporary log for the purpose of creating a drop down list
    //from this list, the user can decide where they are getting the category list from
    Settings settings = Env.store.state.settingsState.settings.value;

    defaultLog = Log(
        name: 'Default',
        id: 'default',
        currency: 'CAD',
        uid: Env.store.state.authState.user.value.id,
        categories: settings.defaultCategories,
        subcategories: settings.defaultSubcategories);
    temporaryLogs = widget.logs.entries.map((e) => e.value).toList();
    temporaryLogs.insert(0, defaultLog);
    Env.store.dispatch(LogSetCategories(log: defaultLog));
    currentDropDownSelection = defaultLog;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 1,
          child: Text('Categories Copy From: '),
        ),
        Expanded(
          flex: 3,
          child: DropdownButton<Log>(
            //TODO order preference logs and set default to first log if not navigating from the log itself
            value: currentDropDownSelection,
            isExpanded: true,
            onChanged: (Log? log) {
              Env.store.dispatch(LogSetCategories(log: log, userUpdated: true));
              currentDropDownSelection = log;
            },
            items: temporaryLogs.map((Log? log) {
              return DropdownMenuItem<Log>(
                value: log,
                child: Text(
                  log!.name!,
                  overflow: TextOverflow.visible,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
