import 'package:collection/collection.dart' show IterableExtension;
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/common_widgets/app_button.dart';
import '../../currency/currency_ui/app_currency_picker.dart';
import '../../app/common_widgets/date_button.dart';
import '../../app/common_widgets/loading_indicator.dart';
import '../../app/common_widgets/simple_confirmation_dialog.dart';
import '../../categories/categories_model/app_category/app_category.dart';
import '../../categories/categories_screens/category_button.dart';
import '../../categories/categories_screens/entry_category_list_dialog.dart';
import '../../env.dart';
import '../../log/log_model/log.dart';
import '../../member/member_model/entry_member_model/entry_member.dart';
import '../../member/member_ui/entry_member_ui/entry_member_list.dart';
import '../../store/actions/entries_actions.dart';
import '../../store/actions/logs_actions.dart';
import '../../store/actions/single_entry_actions.dart';
import '../../store/connect_state.dart';
import '../../tags/tags_ui/tag_picker.dart';
import '../../currency/currency_utils/currency_formatters.dart';
import '../../utils/db_consts.dart';
import '../../utils/keys.dart';
import '../../utils/utils.dart';
import '../entry_model/app_entry.dart';
import '../entry_model/single_entry_state.dart';

//TODO this does not load the modal, the state isn't changed until the entire submit action is completed
class AddEditEntryScreen extends StatelessWidget {
  AddEditEntryScreen({Key? key}) : super(key: key);

  void _save({required AppEntry? entry}) {
    Env.store.dispatch(EntryAddUpdateEntryAndTags(entry: entry));
    Get.back();
  }

  Future<bool> _closeConfirmationDialog({required bool canSave, required AppEntry? entry}) async {
    bool onWillPop = false;
    await Get.dialog(
      SimpleConfirmationDialog(
        title: canSave ? 'Save changes?' : 'Discard changes?',
        confirmText: 'Save',
        canConfirm: canSave,
        onTapConfirm: (pop) {
          onWillPop = pop;
          if (onWillPop) {
            _save(entry: entry);
          }
        },
        onTapDiscard: (pop) {
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
    AppEntry? entry;
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
            Log log = Env.store.state.logsState.logs[entry!.logId]!;

            return WillPopScope(
              onWillPop: () async {
                if (singleEntryState.userUpdated) {
                  return _closeConfirmationDialog(canSave: singleEntryState.canSave, entry: entry);
                } else {
                  _updateCategoriesOnClose();
                  return true;
                }
              },
              child: Stack(
                children: [
                  Scaffold(
                    appBar: _buildAppBar(entry: entry, singleEntryState: singleEntryState, log: log),
                    body: _buildContents(context: context, entryState: singleEntryState, log: log, entry: entry!),
                  ),
                  ModalLoadingIndicator(loadingMessage: '', activate: singleEntryState.processing),
                ],
              ),
            );
          }
        });
  }

  AppBar _buildAppBar({required AppEntry? entry, required SingleEntryState singleEntryState, required Log log}) {
    bool canSave = singleEntryState.canSave;

    return AppBar(
      title: Text('Entry'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          if (singleEntryState.userUpdated) {
            _closeConfirmationDialog(canSave: canSave, entry: entry);
          } else {
            Get.back();
          }
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.check,
            color: canSave ? Colors.white : Colors.grey,
          ),
          onPressed: canSave ? () => {_save(entry: entry)} : null,
        ),
        _buildDeleteEntryButton(entry: entry),
      ],
    );
  }

  Widget _buildContents(
      {required BuildContext context,
      required SingleEntryState entryState,
      required Log log,
      required AppEntry entry}) {
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
      {required BuildContext context,
      required SingleEntryState entryState,
      required Log log,
      required AppEntry entry}) {
    bool canSave = entryState.canSave;
    bool foreignTransaction = entry.currency != log.currency;
    Currency logCurrency = CurrencyService().findByCode(log.currency!)!;

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
                title: 'Entry Currency',
                buttonLabel: currencyLabelFromCode(currencyCode: entry.currency),
                withConversionRates: true,
                unFocus: () {
                  Env.store.dispatch(EntryClearAllFocus());
                },
                referenceCurrency: log.currency!,
                returnCurrency: (currency) {
                  Env.store.dispatch(EntryUpdateCurrency(currency: currency));
                  Get.back();
                }),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (foreignTransaction)
                  _entryTotalForeignCurrency(
                    entry: entry,
                    currency: CurrencyService().findByCode(entry.currency)!,
                    foreignTransaction: foreignTransaction,
                  ),
                if (foreignTransaction) SizedBox(height: 4.0),
                _entryTotalLogCurrency(
                  entry: entry,
                  currency: logCurrency,
                  foreignTransaction: foreignTransaction,
                ),
              ],
            )
          ],
        ),
        SizedBox(height: 10),
        EntryMembersListView(
            currencyCode: entry.currency,
            members: entryState.selectedEntry.value.entryMembers,
            log: log,
            userUpdated: entryState.userUpdated,
            entryId: entry.id),

        _distributeAmountButtons(
            members: entryState.selectedEntry.value.entryMembers,
            canSave: canSave,
            logCurrency: logCurrency,
            remainingSpending: entryState.remainingSpending),
        SizedBox(height: 10.0),
        DateButton(
          datePickerType: DatePickerType.entry,
          initialDateTime: entry.dateTime,
          label: 'Select Date',
          onSave: (newDateTIme) => Env.store.dispatch(EntryUpdateDateTime(dateTime: newDateTIme)),
        ),
        SizedBox(height: 10.0),
        _categoryButton(categories: entryState.categories, entry: entry, newEntry: entryState.newEntry),
        //Transfer funds and No_category do not have a sub categories
        if (entry.categoryId != null && entry.categoryId != NO_CATEGORY && entry.categoryId != TRANSFER_FUNDS)
          _subcategoryButton(subcategories: entryState.subcategories, entry: entry),
        _commentFormField(entry: entry, commentFocusNode: entryState.commentFocusNode.value),
        TagPicker(),
        SizedBox(height: 400.0),
      ],
    );
  }

  Text _entryTotalLogCurrency({
    required AppEntry entry,
    required Currency currency,
    required bool foreignTransaction,
  }) {
    return Text(
      '${foreignTransaction ? '${currency.code}: ' : 'Total: '} ${formattedAmount(
        value: entry.amount,
        showSeparators: true,
        currency: currency,
        showSymbol: true,
        showTrailingZeros: true,
      )}',
      style: foreignTransaction
          ? TextStyle(fontWeight: FontWeight.normal, fontSize: 12.0)
          : TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
    );
  }

  Text _entryTotalForeignCurrency({
    required AppEntry entry,
    required Currency currency,
    required bool foreignTransaction,
  }) {
    return Text(
      '${formattedAmount(
        value: entry.amountForeign ?? 0,
        showSeparators: true,
        currency: currency,
        showSymbol: true,
        showTrailingZeros: true,
        showCurrency: true,
      )}',
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
    );
  }

  Widget _categoryButton({required AppEntry entry, required List<AppCategory> categories, required bool newEntry}) {
    return CategoryButton(
      entry: true,
      newEntry: newEntry,
      label: 'Select a Category',
      onPressed: () => {
        Env.store.dispatch(EntryClearAllFocus()),
        Get.dialog(
          EntryCategoryListDialog(
            categoryOrSubcategory: CategoryOrSubcategory.category,
            key: ExpenseKeys.categoriesDialog,
          ),
        ),
      },
      category: categories.firstWhere((element) => element.id == entry.categoryId,
          orElse: () => categories.firstWhere((element) => element.id == NO_CATEGORY)),
    );
  }

  Widget _subcategoryButton({required AppEntry entry, required List<AppCategory> subcategories}) {
    return CategoryButton(
      entry: true,
      label: 'Select a Subcategory',
      onPressed: () => {
        Env.store.dispatch(EntryClearAllFocus()),
        Get.dialog(
          EntryCategoryListDialog(
            categoryOrSubcategory: CategoryOrSubcategory.subcategory,
            key: ExpenseKeys.subcategoriesDialog,
          ),
        ),
      },
      category: entry.subcategoryId == null
          ? null
          : subcategories.firstWhereOrNull((element) => element.id == entry.subcategoryId)!,
    );
  }

  Widget _commentFormField({required AppEntry entry, required FocusNode commentFocusNode}) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Comment'),
      initialValue: entry.comment,
      focusNode: commentFocusNode,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (value) => Env.store.dispatch(
        EntryUpdateComment(comment: value),
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
            onTapConfirm: (confirmDelete) {
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

  Widget _buildDeleteEntryButton({AppEntry? entry}) {
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
    Env.store.dispatch(LogUpdateCategoriesSubcategoriesOnEntryScreenClose());
  }

  Widget _distributeAmountButtons(
      {required Map<String?, EntryMember?> members,
      required bool canSave,
      required Currency logCurrency,
      required int remainingSpending}) {
    if (!canSave && remainingSpending != 0) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          canSave ? Container() : SizedBox(height: 10.0),
          Row(
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
                          text: '${formattedAmount(value: remainingSpending, currency: logCurrency)}',
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
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  )),
            ],
          ),
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
