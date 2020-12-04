import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/app/splash_screen.dart';
import 'package:expenses/entry/entry_model/entry_state.dart';
import 'package:expenses/entry/entry_screen/entries_date_button.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/category_list_dialog.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';

import 'package:expenses/tags/tags_ui/tag_picker.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//TODO need to modify back button to dump states
//TODO change back to stateful widget to utilize focus node
class AddEditEntriesScreen extends StatelessWidget {
  AddEditEntriesScreen({Key key}) : super(key: key);

  void _submit({@required EntryState entryState, @required MyEntry entry, @required Log log}) {
    Env.store.dispatch(UpdateEntryState(savingEntry: true));

    if (entry.id != null &&
        entry !=
            Env.store.state.entriesState.entries.entries
                .map((e) => e.value)
                .toList()
                .firstWhere((element) => element.id == entry.id)) {
      //update entry if id is not null and thus already exists an the entry has been modified
      Env.entriesFetcher.updateEntry(entry);
    } else if (entry.id == null) {
      Env.entriesFetcher.addEntry(entry);
    }

    Get.back();

    Env.logsFetcher.updateLog(log.copyWith(tags: Env.store.state.entryState.logTagList));

    Env.store.dispatch(ClearEntryState());
  }

  @override
  Widget build(BuildContext context) {

    return ConnectState<EntryState>(
        where: notIdentical,
        map: (state) => state.entryState,
        builder: (entryState) {
          //TODO error on saving from existing entry, likely a rebuild error due to rebuilding before popping, probably use a future delay to handle
          if (true/*!entryState.savingEntry && entryState.selectedEntry.isSome*/) {
            MyEntry entry;
            Log log;
            entry = entryState.selectedEntry.value;
            log = Env.store.state.logsState.logs[entry.logId];

            print('Rendering AddEditEntriesScreen');
            print('entry $entry');

            return WillPopScope(
              onWillPop: () async => false,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Entry'),
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () => closeEntryScreen(),
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (entry?.amount != null) _submit(entryState: entryState, entry: entry, log: log);
                      },
                    ),
                    entry?.id == null
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
                body: _buildContents(context: context, entryState: entryState, log: log, entry: entry),
              ),
            );
          } else {
            //TODO change to saving entry screen
            return SplashScreen();
          }
        });
  }

  Widget _buildContents(
      {@required BuildContext context, @required EntryState entryState, @required Log log, @required MyEntry entry}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildForm(context: context, entryState: entryState, log: log, entry: entry),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
      {@required BuildContext context, @required EntryState entryState, @required Log log, @required MyEntry entry}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Log: '),
            _logNameDropDown(entryState: entryState),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MyCurrencyPicker(
                currency: entry?.currency,
                returnCurrency: (currency) => Env.store.dispatch(UpdateSelectedEntry(currency: currency))),
            Expanded(
              child: TextFormField(
                autofocus: entry.id == null ? true : false,
                //auto focus on adding the value if the entry is new
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Amount'),
                initialValue: entry?.amount?.toStringAsFixed(2) ?? null,
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
        //CategoryPicker(entry: entriesState.selectedEntry.value),
        SizedBox(height: 10.0),
        EntriesDateButton(context: context, log: log, entry: entry),
        SizedBox(height: 10.0),
        entry?.logId == null ? Container() : _categoryButton(log: log, entry: entry),
        entry?.categoryId == null ? Container() : _subcategoryButton(log: log, entry: entry),
        _commentFormField(entry: entry),
        TagPicker(),
      ],
    );
  }

  CategoryButton _categoryButton({@required Log log, @required MyEntry entry}) {
    return CategoryButton(
      label: 'Select a Category',
      onPressed: () => {
        Get.dialog(
          CategoryListDialog(
            categoryOrSubcategory: CategoryOrSubcategory.category,
            log: log,
            key: ExpenseKeys.categoriesDialog,
            settingsLogEntry: SettingsLogEntry.entry,
          ),
        ),
      },
      category:
          entry?.categoryId == null ? null : log.categories.firstWhere((element) => element.id == entry.categoryId),
    );
  }

  CategoryButton _subcategoryButton({@required Log log, @required MyEntry entry}) {
    return CategoryButton(
      label: 'Select a Subcategory',
      onPressed: () => {
        Get.dialog(
          CategoryListDialog(
            categoryOrSubcategory: CategoryOrSubcategory.subcategory,
            log: log,
            key: ExpenseKeys.subcategoriesDialog,
            settingsLogEntry: SettingsLogEntry.entry,
          ),
        ),
      },
      category: entry?.subcategoryId == null
          ? null
          : log.subcategories.firstWhere((element) => element.id == entry.subcategoryId),
    );
  }

  TextFormField _commentFormField({@required MyEntry entry}) {
    return TextFormField(
      decoration: InputDecoration(hintText: 'Comment'),
      initialValue: entry?.comment,
      onChanged: (value) => Env.store.dispatch(
        UpdateSelectedEntry(comment: value),
      ),
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Delete Entry':
        Env.entriesFetcher.deleteEntry(Env.store.state.entryState.selectedEntry.value);
        closeEntryScreen();
        break;
    }
  }

  void closeEntryScreen() {
    Get.back();
    Env.store.dispatch(ClearEntryState());
  }

  //TODO similar code used here and in settings - refactor to use same widget and pass required functions only
  Widget _logNameDropDown({@required EntryState entryState}) {
    if (Env.store.state.logsState.logs.isNotEmpty) {
      List<Log> _logs = Env.store.state.logsState.logs.entries.map((e) => e.value).toList();

      return DropdownButton<Log>(
        //TODO order preference logs and set default to first log if not navigating from the log itself
        value: Env.store.state.logsState.logs[entryState.selectedEntry.value.logId],
        onChanged: (Log log) {
          Env.store.dispatch(ChangeEntryLog(log: log));
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
