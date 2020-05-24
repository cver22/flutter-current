import 'package:currency_pickers/utils/utils.dart';
import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/my_currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditLogPage extends StatefulWidget {
  final Log log;
  const AddEditLogPage({Key key, this.log}) : super(key: key);

  @override
  _AddEditLogPageState createState() => _AddEditLogPageState();
}

class _AddEditLogPageState extends State<AddEditLogPage> {
  //TODO text editing controllers and dispose
  Log _log;
  String _currency;
  String _name;
  LogsBloc _logsBloc;

  void _submit() {
    print('submit pressed');
    _log = _log.copyWith(logName: _name, currency: _currency);

    if (_log.id != null) {
      _logsBloc..add(LogUpdated(log: _log));
    } else {
      _logsBloc..add(LogAdded(log: _log));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _log = widget.log == null ? Log() : widget.log;
    _currency = _log?.currency ?? 'ca';
    _name = _log?.logName ?? null;
    _logsBloc = BlocProvider.of<LogsBloc>(context);

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
  }

  Widget _buildContents(BuildContext context) {
    return BlocBuilder<LogsBloc, LogsState>(builder: (context, state) {
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
                          'Currency: ${CurrencyPickerUtils.getCountryByIsoCode(_currency).currencyCode}'),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildForm() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Log Title'),
      initialValue: _name,
      onChanged: (value) => _name = value,
      //TODO validate in the bloc, name cannot be empty
      //TODO need controllers
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Delete Log':
        _logsBloc..add(LogDeleted(log: _log));
        Navigator.pop(context);
        break;
    }
  }
}
