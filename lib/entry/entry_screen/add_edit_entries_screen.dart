import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/app/splash_screen.dart';
import 'package:expenses/entry/entry_screen/entries_date_button.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/category_list_dialog.dart';
import 'package:expenses/entry/entry_model/entries_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/tags/tags_ui/tag_picker.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses/utils/maybe.dart';

//TODO change back to stateful widget to utilize focus node
class AddEditEntriesScreen extends StatelessWidget {
  AddEditEntriesScreen({Key key}) : super(key: key);

  void _submit({@required MyEntry entry, @required Log log}) {
    print('saving entry $entry');
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
    List<Tag> logTags = log.tags;
    Env.store.state.tagState.newTags.forEach((tag) {logTags.add(tag.copyWith(id: Uuid().v4())); });
    Env.logsFetcher.updateLog(log.copyWith(tags: logTags));
    Env.store.dispatch(ClearSelectedEntry());
    Env.store.dispatch(UpdateTagState(newTags: [], selectedTag: Maybe.none()));

  }

  @override
  Widget build(BuildContext context) {
    MyEntry _entry;
    Log _log;
    return ConnectState<EntriesState>(
        where: notIdentical,
        map: (state) => state.entriesState,
        builder: (entriesState) {
          //TODO error on saving from existing entry, likely a rebuild error due to rebuilding before popping, probably use a future delay to handle
          if(Env.store.state.entriesState.selectedEntry.isSome) {

            _entry = Env.store.state.entriesState.selectedEntry.value;
            _log = Env.store.state.logsState.logs[_entry.logId];

            print('Rendering AddEditEntriesScreen');
            print('entry $_entry');

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
                      if (_entry?.amount != null) _submit(entry: _entry, log: _log);
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
              body: _buildContents(context: context, entriesState: entriesState, log: _log, entry: _entry),
            );
          } else {
            //TODO change to saving entry screen
            return SplashScreen();
          }


        });
  }

  Widget _buildContents(
      {@required BuildContext context,
      @required EntriesState entriesState,
      @required Log log,
      @required MyEntry entry}) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildForm(context: context, entriesState: entriesState, log: log, entry: entry),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
      {@required BuildContext context,
      @required EntriesState entriesState,
      @required Log log,
      @required MyEntry entry}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Log: '),
            _logNameDropDown(entriesState: entriesState),
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
                autofocus: true,
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
        Env.entriesFetcher.deleteEntry(Env.store.state.entriesState.selectedEntry.value);
        Get.back();
        break;
    }
  }

  //TODO similar code used here and in settings - refactor to use same widget and pass required functions only
  Widget _logNameDropDown({@required EntriesState entriesState}) {
    if (Env.store.state.logsState.logs.isNotEmpty) {
      List<Log> _logs = Env.store.state.logsState.logs.entries.map((e) => e.value).toList();

      return DropdownButton<Log>(
        //TODO order preference logs and set default to first log if not navigating from the log itself
        value: Env.store.state.logsState.logs[entriesState.selectedEntry.value.logId],
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
