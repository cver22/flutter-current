import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/app/common_widgets/my_currency_picker.dart';
import 'package:expenses/categories/categories_screens/entry_category_list_dialog.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_screen/entry_date_button.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/categories/categories_screens/category_list_dialog.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_ui/entry_member_ui/entry_member_list.dart';
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
class AddEditEntryScreen extends StatelessWidget {
  AddEditEntryScreen({Key key}) : super(key: key);

  void _submit({@required MyEntry entry}) {
    Env.store.dispatch(AddUpdateSingleEntryAndTags(entry: entry));
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
                  appBar: _buildAppBar(entry, singleEntryState, log),
                  body: _buildContents(context: context, entryState: singleEntryState, log: log, entry: entry),
                ),
                ModalLoadingIndicator(loadingMessage: '', activate: singleEntryState.savingEntry),
              ],
            ),
          );
        });
  }

  AppBar _buildAppBar(MyEntry entry, SingleEntryState singleEntryState, Log log) {
    return AppBar(
      title: Text('Entry'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => closeEntryScreen(),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: _canSubmit(entry: entry) ? Colors.white : Colors.grey,
          ),
          onPressed: _canSubmit(entry: entry) ? () => {_submit(entry: entry)} : null,
        ),
        _buildDeleteEntryButton(entry: entry),
      ],
    );
  }

  Widget _buildContents(
      {@required BuildContext context,
      @required SingleEntryState entryState,
      @required Log log,
      @required MyEntry entry}) {
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildForm(context: context, entryState: entryState, log: log, entry: entry),
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
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('Log: ${log.name}'),
            //_logNameDropDown(entry: entry),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MyCurrencyPicker(
                currency: entry?.currency,
                returnCurrency: (currency) => Env.store.dispatch(UpdateSelectedEntry(currency: currency))),
            Text(
                'Total: \$ ${formattedAmount(value: entry.amount).length > 0 ? formattedAmount(value: entry.amount, withSeparator: true) : '0.00'}'), //TODO utilize money package here
          ],
        ),
        SizedBox(height: 10),
        entryState.selectedEntry.isSome
            ? EntryMembersListView(members: entryState.selectedEntry.value.entryMembers, log: log)
            : Container(),
        SizedBox(height: 10.0),
        EntryDateButton(context: context, log: log, entry: entry),
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
          EntryCategoryListDialog(
            categoryOrSubcategory: CategoryOrSubcategory.category,
            key: ExpenseKeys.categoriesDialog,
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
          EntryCategoryListDialog(
            categoryOrSubcategory: CategoryOrSubcategory.subcategory,
            key: ExpenseKeys.subcategoriesDialog,
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

  bool _canSubmit({MyEntry entry}) {
    bool canSubmit = false;
    if (entry?.amount != null && entry.amount != 0) {
      int totalMemberSpend = 0;

      entry.entryMembers.forEach((key, value) {
        if (value.spending) {
          totalMemberSpend += value.spent;
        }
      });
      if (totalMemberSpend == entry.amount) {
        canSubmit = true;
      }
    }
    return canSubmit;
  }

  Widget _buildDeleteEntryButton({MyEntry entry}) {
    return entry?.id == null
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
          );
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
