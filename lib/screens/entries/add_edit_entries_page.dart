import 'package:expenses/blocs/entries_bloc/bloc.dart';
import 'package:expenses/blocs/entries_bloc/entries_bloc.dart';
import 'package:expenses/blocs/logs_bloc/bloc.dart';
import 'package:expenses/models/entry/entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/my_currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditEntriesPage extends StatefulWidget {
  final Entry entry;
  final Log log;

  const AddEditEntriesPage({Key key, this.entry, this.log}) : super(key: key);

  @override
  _AddEditEntriesPageState createState() => _AddEditEntriesPageState();
}

class _AddEditEntriesPageState extends State<AddEditEntriesPage> {
  Entry _entry;
  String _currency;
  String _logId;
  String _category;
  String _subcategory;
  double _amount;
  String _comment;
  DateTime _dateTime;
  EntriesBloc _entriesBloc;
  Log _log;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _entry = widget.entry == null ? Entry() : widget.entry;
    _currency = _entry?.currency ?? 'ca';
    _logId = _entry?.logId ??
        widget?.log?.id; //TODO pass logId by clicking on log or some other way
    _category = _entry?.category ?? null;
    _subcategory = _entry?.subcategory ?? null;
    _amount = _entry?.amount ?? null;
    _comment = _entry?.comment ?? null;
    _dateTime = _entry?.dateTime ?? DateTime.now();
    _entriesBloc = BlocProvider.of<EntriesBloc>(context);
    _log = widget?.log;
  }

  void _submit() {
    print('submit entry pressed');
    _entry = _entry.copyWith(
        currency: _currency,
        logId: _log.id,
        category: _category,
        subcategory: _subcategory,
        amount: _amount,
        comment: _comment,
        dateTime: _dateTime);

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
              if (_amount != null) _submit();
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
                currency: _currency,
                returnCurrency: (currency) => _currency = currency),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Amount'),
                initialValue: _amount?.toStringAsFixed(2) ?? null,
                onChanged: (value) => _amount = double.parse(value),
                //TODO need controllers
              ),
            ),
          ],
        ),
        TextFormField(
          decoration: InputDecoration(hintText: 'Comment'),
          initialValue: _comment,
          onChanged: (value) => _comment = value,
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
