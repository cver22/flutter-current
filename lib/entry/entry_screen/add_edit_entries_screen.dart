import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_screen/entries_date_button.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/category_list_dialog.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_ui/entry_member_list.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tags_ui/tag_picker.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


//TODO change back to stateful widget to utilize focus node or add to single entry state?
//TODO this does not load the modal, the state isn't changed until the entire submit action is completed
class AddEditEntriesScreen extends StatelessWidget {
  AddEditEntriesScreen({Key key}) : super(key: key);

  void _submit({@required SingleEntryState entryState, @required MyEntry entry, @required Log log}) {
    Env.store.dispatch(AddUpdateSingleEntry(entry: entry, log: log));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    MyEntry entry;
    return ConnectState<SingleEntryState>(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (singleEntryState) {
          print('Rendering AddEditEntriesScreen');

          if (!singleEntryState.savingEntry && singleEntryState.selectedEntry.isSome) {
            entry = singleEntryState.selectedEntry.value;
          }
          Log log;
          log = Env.store.state.logsState.logs[entry.logId];

          return WillPopScope(
            onWillPop: () async => false, //TODO need to implement will pop?
            child: Stack(
              children: [
                Scaffold(
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
                          color: entry?.amount != null ? Colors.white : Colors.grey,
                        ),
                        onPressed: entry?.amount != null
                            ? () => {_submit(entryState: singleEntryState, entry: entry, log: log)}
                            : null,
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
                  body: _buildContents(context: context, entryState: singleEntryState, log: log, entry: entry),
                ),
                ModalLoadingIndicator(loadingMessage: '', activate: singleEntryState.savingEntry),
              ],
            ),
          );
        });
  }

  Widget _buildContents(
      {@required BuildContext context,
      @required SingleEntryState entryState,
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
                _buildForm(context: context, entryState: entryState, log: log, entry: entry),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(
      {@required BuildContext context,
      @required SingleEntryState entryState,
      @required Log log,
      @required MyEntry entry}) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Log: ${log.logName}'),
            //_logNameDropDown(entry: entry),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MyCurrencyPicker(
                currency: entry?.currency,
                returnCurrency: (currency) => Env.store.dispatch(UpdateSelectedEntry(currency: currency))),
            Text('Total: \$ ${formattedAmount(value: entry.amount)}'), //TODO utilize money package here
          ],
        ),
        EntryMembersListView(
            members: entryState.selectedEntry.value.entryMembers, log: log, paidOrSpent: PaidOrSpent.paid),
        SizedBox(height: 10.0),
        EntriesDateButton(context: context, log: log, entry: entry),
        SizedBox(height: 10.0),
        entry?.logId == null ? Container() : _categoryButton(log: log, entry: entry),
        entry?.categoryId == null ? Container() : _subcategoryButton(log: log, entry: entry),
        _commentFormField(entry: entry),
        TagPicker(),
        //TODO use this when done resting
        /*entry.entryMembers.length > 1 ? EntryMembersListView(
            members: entryState.selectedEntry.value.entryMembers, log: log, paidOrSpent: PaidOrSpent.spent) : Container(),*/
        EntryMembersListView(
            members: entryState.selectedEntry.value.entryMembers, log: log, paidOrSpent: PaidOrSpent.spent), //TODO Remove this when done testing
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
        Env.store.dispatch(DeleteSelectedEntry());
        closeEntryScreen();
        break;
    }
  }

  void closeEntryScreen() {
    Env.store.dispatch(SingleEntryProcessing());
    Env.store.dispatch(ClearEntryState());
    Get.back();
  }

//currently not in use due to high level of complications of switching an entry from one log to another, also due to multiple user issues
/*//TODO similar code used here and in settings - refactor to use same widget and pass required functions only
  Widget _logNameDropDown({@required MyEntry entry}) {
    if (Env.store.state.logsState.logs.isNotEmpty) {
      List<Log> _logs = Env.store.state.logsState.logs.entries.map((e) => e.value).toList();

      return DropdownButton<Log>(
        //TODO order preference logs and set default to first log if not navigating from the log itself
        value: Env.store.state.logsState.logs[entry.logId],
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
  }*/
}


