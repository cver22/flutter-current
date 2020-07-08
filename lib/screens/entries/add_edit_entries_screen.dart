import 'package:expenses/env.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/category_picker.dart';
import 'package:expenses/screens/common_widgets/my_currency_picker.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:flutter/material.dart';

//TODO refactor to build with ConnectState Widget to allow rebuild, issue created when I changed the log

class AddEditEntriesScreen extends StatefulWidget {
  const AddEditEntriesScreen({Key key}) : super(key: key);

  @override
  _AddEditEntriesScreenState createState() => _AddEditEntriesScreenState();
}

class _AddEditEntriesScreenState extends State<AddEditEntriesScreen> {
  MyEntry _entry;
  Log _log;

  @override
  void initState() {
    super.initState();
    //TODO set log based on default
    if (Env.store.state.entriesState.selectedEntry.isNone) {
      Env.store.dispatch(SetNewSelectedEntry());
    }
    _entry = Env.store.state.entriesState.selectedEntry.value;

    if (Env.store.state.logsState.selectedLog.isSome) {
      _log = Env.store.state.logsState.selectedLog.value;
      _entry = _entry.copyWith(logId: _log.id);
    }


    if (_entry?.currency == null && _log?.currency != null) {
      _entry = _entry.copyWith(currency: _log.currency);
    }
  }

  void _submit() {
    if (_entry.id != null) {
      Env.entriesFetcher.updateEntry(_entry);
    } else {
      Env.entriesFetcher.addEntry(_entry);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entry'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () {
              if (_entry?.amount != null) _submit();
            },
          ),
          _entry?.id == null
              ? Container()
              : PopupMenuButton<String>(
                  onSelected: handleClick,
                  itemBuilder: (BuildContext context) {
                    return {'Delete Entry'}.map((String choice) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Log: '),
            _logNameDropDown(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MyCurrencyPicker(
                currency: _entry?.currency,
                returnCurrency: (currency) =>
                    _entry = _entry.copyWith(currency: currency)),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Amount'),
                initialValue: _entry?.amount?.toStringAsFixed(2) ?? null,
                onChanged: (value) =>
                    _entry = _entry.copyWith(amount: double.parse(value)),
                //TODO need controllers
              ),
            ),
          ],
        ),
        CategoryPicker(log: _log),
        TextFormField(
          decoration: InputDecoration(hintText: 'Comment'),
          initialValue: _entry?.comment,
          onChanged: (value) => _entry = _entry.copyWith(currency: value),
          //TODO validate in the bloc, name cannot be empty
          //TODO need controllers
        ),
      ],
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Delete Entry':
        Env.entriesFetcher.deleteEntry(_entry);
        Navigator.pop(context);
        break;
    }
  }

  Widget _logNameDropDown() {
    if (Env.store.state.logsState.logs.isNotEmpty) {
      //TODO state should handle what is active and not active
      List<Log> _allLogs = Env.store.state.logsState.logs.entries
          .map((e) => e.value)
          .where((e) => e.active == true)
          .toList();
      List<Log> _displayLogs = [];

      for (int i = 0; i < _allLogs.length; i++) {
        if (_allLogs[i].active) {
          _displayLogs.add(_allLogs[i]);
        }
      }

      return DropdownButton<Log>(
        //TODO order preference logs and set default to first log if not navigating from the log itself
        value: _log,
        onChanged: (Log value) {
          setState(() {
            _log = value;
            _entry = _entry.copyWith(currency: _log.currency);
            //TODO need to update current currency in picker
          });
        },
        items: _displayLogs.map((Log log) {
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
}
