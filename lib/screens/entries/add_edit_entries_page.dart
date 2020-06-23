import 'package:expenses/blocs/entries_bloc/bloc.dart';
import 'package:expenses/blocs/entries_bloc/entries_bloc.dart';
import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/catergory_picker.dart';
import 'package:expenses/screens/common_widgets/my_currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class AddEditEntriesPage extends StatefulWidget {
  final MyEntry entry;
  final Log log;

  const AddEditEntriesPage({Key key, this.entry, this.log}) : super(key: key);

  @override
  _AddEditEntriesPageState createState() => _AddEditEntriesPageState();
}

class _AddEditEntriesPageState extends State<AddEditEntriesPage> {
  MyEntry _entry;
  EntriesBloc _entriesBloc;
  Log _log;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _log = widget?.log;
    _entriesBloc = BlocProvider.of<EntriesBloc>(context);

    //entryBloc handles null value


   
    if (_entry?.currency == null && _log?.currency != null) {
      _entry = _entry.copyWith(currency: _log.currency);
    }
  }

  void _submit() {
    if (_entry.id != null) {
      _entriesBloc..add(EntryUpdated(entry: _entry));
    } else {
      _entriesBloc..add(EntryAdded(entry: _entry));
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
              if (_entry.amount != null) _submit();
            }, //TODO need to use state to take care of this with SavingLogState
          ),
          _entry.id == null
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
    return BlocBuilder<EntriesBloc, EntriesState>(builder: (context, state) {
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
    });
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
                currency: _entry.currency,
                returnCurrency: (currency) =>
                    _entry = _entry.copyWith(currency: currency)),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Amount'),
                initialValue: _entry.amount?.toStringAsFixed(2) ?? null,
                onChanged: (value) =>
                    _entry = _entry.copyWith(amount: double.parse(value)),
                //TODO need controllers
              ),
            ),
          ],
        ),
        //TODO pass logsbloc
        //TODO pass entry via a provider so all screens are updating the same entry
        CategoryPicker(log: _log),
        TextFormField(
          decoration: InputDecoration(hintText: 'Comment'),
          initialValue: _entry.comment,
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
        _entriesBloc..add(EntryDeleted(entry: _entry));
        Navigator.pop(context);
        break;
    }
  }

  Widget _logNameDropDown() {
    return BlocBuilder<LogsBloc, LogsState>(
        // ignore: missing_return
        builder: (context, state) {
      if (state is LogsLoaded) {
        List<Log> _allLogs = state.logs;
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
      }
    });
  }
}
