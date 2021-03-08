import 'package:expenses/app/common_widgets/app_button.dart';
import 'package:expenses/app/common_widgets/date_button.dart';
import 'package:expenses/app/common_widgets/simple_confirmation_dialog.dart';
import 'package:expenses/app/common_widgets/loading_indicator.dart';
import 'package:expenses/app/common_widgets/app_currency_picker.dart';
import 'package:expenses/categories/categories_model/app_category/app_category.dart';
import 'package:expenses/categories/categories_screens/entry_category_list_dialog.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/categories/categories_screens/category_button.dart';
import 'package:expenses/entry/entry_model/app_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/member/member_ui/entry_member_ui/entry_member_list.dart';
import 'package:expenses/store/actions/entries_actions.dart';
import 'package:expenses/store/actions/logs_actions.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/store/actions/single_entry_actions.dart';
import 'package:expenses/store/connect_state.dart';
import 'package:expenses/tags/tags_ui/tag_picker.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/keys.dart';
import 'package:expenses/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//TODO this does not load the modal, the state isn't changed until the entire submit action is completed
class AddEditEntryScreen extends StatelessWidget {
  AddEditEntryScreen({Key key}) : super(key: key);

  void _submit({@required MyEntry entry}) {
    Env.store.dispatch(AddUpdateSingleEntryAndTags(entry: entry));
    Get.back();
  }

  Future<bool> _closeConfirmationDialog() async {
    bool onWillPop = false;
    await Get.dialog(
      SimpleConfirmationDialog(
        title: 'Discard changes?',
        onTapYes: (pop) {
          onWillPop = pop;
          if (onWillPop) {
            _updateCategoriesOnClose();
            Get.back();
          }
        },
      ),
    );
    return onWillPop;
  }

  @override
  Widget build(BuildContext context) {
    MyEntry entry;
    bool canSubmit = false;
    return ConnectState<SingleEntryState>(
        where: notIdentical,
        map: (state) => state.singleEntryState,
        builder: (singleEntryState) {
          print('Rendering AddEditEntriesScreen');

          if (singleEntryState.processing) {
            return Container(); //TODO replace with spinner
          } else {
            if (!singleEntryState.processing && singleEntryState.selectedEntry.isSome) {
              entry = singleEntryState.selectedEntry.value;
            }
            Log log;
            log = Env.store.state.logsState.logs[entry.logId];
            canSubmit = _canSubmit(entry: entry);

            return WillPopScope(
              onWillPop: () async {
                if (singleEntryState.userUpdated) {
                  return _closeConfirmationDialog();
                } else {
                  _updateCategoriesOnClose();
                  return true;
                }
              },
              child: Stack(
                children: [
                  Scaffold(
                    appBar:
                        _buildAppBar(entry: entry, singleEntryState: singleEntryState, log: log, canSubmit: canSubmit),
                    body: _buildContents(
                        context: context, entryState: singleEntryState, log: log, entry: entry, canSubmit: canSubmit),
                  ),
                  ModalLoadingIndicator(loadingMessage: '', activate: singleEntryState.processing),
                ],
              ),
            );
          }
        });
  }

  AppBar _buildAppBar(
      {@required MyEntry entry,
      @required SingleEntryState singleEntryState,
      @required Log log,
      @required bool canSubmit}) {
    return AppBar(
      title: Text('Entry'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (singleEntryState.userUpdated) {
            _closeConfirmationDialog();
          } else {
            Get.back();
          }
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: canSubmit ? Colors.white : Colors.grey,
          ),
          onPressed: canSubmit ? () => {_submit(entry: entry)} : null,
        ),
        _buildDeleteEntryButton(entry: entry),
      ],
    );
  }

  Widget _buildContents(
      {@required BuildContext context,
      @required SingleEntryState entryState,
      @required Log log,
      @required MyEntry entry,
      @required bool canSubmit}) {
    return SingleChildScrollView(
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildForm(context: context, entryState: entryState, log: log, entry: entry, canSubmit: canSubmit),
        ),
      ),
    );
  }

  Widget _buildForm(
      {@required BuildContext context,
      @required SingleEntryState entryState,
      @required Log log,
      @required MyEntry entry,
      @required bool canSubmit}) {
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
            AppCurrencyPicker(
                currency: entry?.currency,
                returnCurrency: (currency) => Env.store.dispatch(UpdateEntryCurrency(currency: currency))),
            Text(
                'Total: \$ ${formattedAmount(value: entry.amount).length > 0 ? formattedAmount(value: entry.amount, withSeparator: true) : '0.00'}'), //TODO utilize money package here
          ],
        ),
        SizedBox(height: 10),
        EntryMembersListView(
            members: entryState.selectedEntry.value.entryMembers,
            log: log,
            userUpdated: entryState.userUpdated,
            entryId: entry.id),
        canSubmit ? Container() : SizedBox(height: 10.0),
        _distributeAmountButtons(members: entryState.selectedEntry.value.entryMembers, canSubmit: canSubmit),
        SizedBox(height: 10.0),
        DateButton(
          initialDateTime: entry.dateTime,
          label: 'Select Date',
          onSave: (newDateTIme) => Env.store.dispatch(UpdateEntryDateTime(dateTime: newDateTIme)),
        ),
        SizedBox(height: 10.0),
        _categoryButton(categories: entryState?.categories, entry: entry),
        //Transfer funds and No_category do not have a sub categories
        _subcategoryButton(subcategories: entryState.subcategories, entry: entry),
        _commentFormField(entry: entry, commentFocusNode: entryState.commentFocusNode.value),
        TagPicker(),
        SizedBox(height: 400.0),
      ],
    );
  }

  Widget _categoryButton({@required MyEntry entry, @required List<AppCategory> categories}) {
    return entry?.logId == null
        ? Container()
        : CategoryButton(
            label: 'Select a Category',
            onPressed: () => {
              Get.dialog(
                EntryCategoryListDialog(
                  categoryOrSubcategory: CategoryOrSubcategory.category,
                  key: ExpenseKeys.categoriesDialog,
                ),
              ),
            },
            category: entry?.categoryId == null
                ? null
                : categories?.firstWhere((element) => element.id == entry.categoryId,
                    orElse: () => categories?.firstWhere((element) => element.id == NO_CATEGORY, orElse: () => null)),
          );
  }

  Widget _subcategoryButton({@required MyEntry entry, @required List<AppCategory> subcategories}) {
    return entry?.categoryId == null || entry?.categoryId == TRANSFER_FUNDS || entry.categoryId == NO_CATEGORY
        ? Container()
        : CategoryButton(
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
                : subcategories?.firstWhere((element) => element.id == entry.subcategoryId, orElse: () => null),
          );
  }

  Widget _commentFormField({@required MyEntry entry, @required FocusNode commentFocusNode}) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Comment'),
      initialValue: entry?.comment,
      focusNode: commentFocusNode,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) => Env.store.dispatch(
        UpdateEntryComment(comment: value),
      ),
      maxLines: 1,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        Env.store.dispatch(EntryNextFocus());
      },
    );
  }

  void handleClick(String value) async {
    switch (value) {
      case 'Delete Entry':
        //confirm deletion
        await Get.dialog(
          SimpleConfirmationDialog(
            title: 'Are you sure you want to delete this Entry?',
            onTapYes: (confirmDelete) {
              if (confirmDelete) {
                Env.store.dispatch(EntriesDeleteSelectedEntry());
                _updateCategoriesOnClose();
                Get.back();
              }
            },
          ),
        );
        break;
    }
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

  _updateCategoriesOnClose() {
    Env.store.dispatch(UpdateLogCategoriesSubcategoriesOnEntryScreenClose());
    Env.store.dispatch(ClearEntryState());
  }

  Widget _distributeAmountButtons({@required Map<String, EntryMember> members, @required bool canSubmit}) {
    int remainingSpending = 0;
    members.forEach((key, member) {
      if (member.paying && member.paid != null) {
        remainingSpending += member.paid;
      }
      if (member.spending && member.spent != null) {
        remainingSpending -= member.spent;
      }
    });

    if (!canSubmit && remainingSpending != 0) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AppButton(
              onPressed: () {
                Env.store.dispatch(EntryDivideRemainingSpending());
              },
              buttonColor: Colors.red[100],
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'Distribute Remaining ', style: TextStyle(color: Colors.black)),
                  TextSpan(
                      text: '\$${formattedAmount(value: remainingSpending)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                ]),
              )),
          AppButton(
              onPressed: () {
                Env.store.dispatch(EntryResetMemberSpendingToAll());
              },
              buttonColor: Colors.red[100],
              child: Text(
                'Reset',
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
        ],
      );
    } else {
      return Container();
    }
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
