import 'package:currency_pickers/utils/utils.dart';
import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditLogScreen extends StatefulWidget {

  const AddEditLogScreen({Key key}) : super(key: key);

  @override
  _AddEditLogScreenState createState() => _AddEditLogScreenState();
}

class _AddEditLogScreenState extends State<AddEditLogScreen> {
  //TODO text editing controllers and dispose
  Log _log = Log();
  String _currency;
  String _name;

  void _submit() {
    print('submit pressed');
    _log = _log.copyWith(logName: _name, currency: _currency);

    if (_log.id != null) {
      Env.logsFetcher.updateLog(_log);
    } else {
      Env.logsFetcher.addLog(_log);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState<LogsState>(
      where: notIdentical,
      map: (state) => state.logsState,
      builder: (logState) {
        if (logState.selectedLog.isSome) {
          _log = logState.selectedLog.value;
        }
        _currency = _log?.currency ?? 'ca'; //TODO change to home currency as default
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
                }, //TODO need to use state to take care of this with SavingLogState
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
          body: _buildContents(context),
        );
      },
    );
  }

  Widget _buildContents(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildForm(),
                SizedBox(height: 16.0),
                _log.uid == null
                    ? MyCurrencyPicker(
                    currency: _currency,
                    returnCurrency: (currency) => _currency = currency)
                    : Text(
                    'Currency: ${CurrencyPickerUtils
                        .getCountryByIsoCode(_currency)
                        .currencyCode}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Log Title'),
      initialValue: _name,
      onChanged: (value) => _name = value,
      //TODO validate name cannot be empty
      //TODO need controllers
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Delete Log':
        Env.logsFetcher.deleteLog(_log);
        Get.back();
        break;
    }
  }
}
