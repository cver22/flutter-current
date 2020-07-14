import 'package:expenses/env.dart';
import 'package:expenses/models/entry/entries_state.dart';
import 'package:expenses/models/entry/my_entry.dart';
import 'package:expenses/models/log/log.dart';
import 'package:expenses/screens/common_widgets/category_picker.dart';
import 'package:expenses/screens/common_widgets/my_currency_picker.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';

//TODO refactor to build with ConnectState Widget to allow rebuild, issue created when I changed the log
//TODO need to handle back button to dump selected entry

class AddEditEntriesScreen extends StatefulWidget {
  const AddEditEntriesScreen({Key key}) : super(key: key);

  @override
  _AddEditEntriesScreenState createState() => _AddEditEntriesScreenState();
}

class _AddEditEntriesScreenState extends State<AddEditEntriesScreen> {
  MyEntry _entry;

  @override
  void initState() {
    super.initState();
    //TODO set log based on default
    if (Env.store.state.entriesState.selectedEntry.isNone) {
      Env.store.dispatch(SetNewSelectedEntry());
      setEntryLogAndCurrency();
    }
  }

  void setEntryLogAndCurrency() {
    if (Env.store.state.logsState.selectedLog.isSome) {
      Log _log = Env.store.state.logsState.selectedLog.value;
      Env.store.dispatch(
          UpdateSelectedEntry(logId: _log.id, currency: _log.currency));
    }
  }

  void _submit() {
    //TODO clear selected entry after saving without causing a fatal rebuild
    print('saving entry $_entry');
    if (_entry.id != null) {
      Env.entriesFetcher.updateEntry(_entry);
    } else {
      Env.entriesFetcher.addEntry(_entry);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (entriesState) {
          _entry = Env.store.state.entriesState.selectedEntry.value;
          print('Rendering AddEditEntriesScreen');
          print('entry $_entry');
          print('log: ${Env.store.state.logsState.selectedLog.value.id}');
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
            body: _buildContents(entriesState),
          );
        });
  }

  Widget _buildContents(EntriesState entriesState) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildForm(entriesState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(EntriesState entriesState) {
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
                returnCurrency: (currency) => Env.store
                    .dispatch(UpdateSelectedEntry(currency: currency))),
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Amount'),
                initialValue: _entry?.amount?.toStringAsFixed(2) ?? null,
                onChanged: (value) => Env.store.dispatch(
                  UpdateSelectedEntry(
                    amount: double.parse(value),
                  ),
                ),
                //TODO need controllers
              ),
            ),
          ],
        ),
        CategoryPicker(entry: entriesState.selectedEntry.value),
        TextFormField(
          decoration: InputDecoration(hintText: 'Comment'),
          initialValue: _entry?.comment,
          onChanged: (value) => Env.store.dispatch(
            UpdateSelectedEntry(comment: value),
            //TODO need controllers
          ),
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
      List<Log> _logs =
          Env.store.state.logsState.logs.entries.map((e) => e.value).toList();

      return DropdownButton<Log>(
        //TODO order preference logs and set default to first log if not navigating from the log itself
        value: Env.store.state.logsState.selectedLog.value,
        onChanged: (Log value) {
          setState(() {
            Env.store.dispatch(SelectLog(logId: value.id));

            Env.store
                .dispatch(ChangeLog(logId: value.id, currency: value.currency));
          });
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
}
