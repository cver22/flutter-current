import 'dart:collection';

import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/auth_user/models/auth_state.dart';
import 'package:expenses/auth_user/models/user.dart';
import 'package:expenses/categories/categories_model/my_category/my_category.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/entry/entry_model/my_entry.dart';
import 'package:expenses/env.dart';
import 'package:expenses/log/log_model/log.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/log/log_totals_model/log_total.dart';
import 'package:expenses/login_register/login_register_model/login_or_register.dart';
import 'package:expenses/login_register/login_register_model/login_reg_state.dart';
import 'package:expenses/member/member_model/entry_member_model/entry_member.dart';
import 'package:expenses/member/member_model/log_member_model/log_member.dart';
import 'package:expenses/settings/settings_model/settings.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/tags/tag_model/tag.dart';
import 'package:expenses/utils/currency.dart';
import 'package:expenses/utils/db_consts.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:expenses/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import 'package:expenses/tags/tag_model/tag_state.dart';
import 'package:expenses/log/log_totals_model/log_totals_state.dart';
import 'package:expenses/account/account_model/account_state.dart';
import 'package:expenses/login_register/login_register_model/login__reg_status.dart';

abstract class MyAction {
  AppState updateState(AppState appState);
}

AppState _updateLogEntriesTagSettingState(
    AppState appState,
    LogsState updateLogState(LogsState logsState),
    EntriesState updateEntriesState(EntriesState entriesState),
    TagState updateTagState(TagState tagState),
    SettingsState updateSettingsState(SettingsState settingsState)) {
  return appState.copyWith(
      logsState: updateLogState(appState.logsState),
      entriesState: updateEntriesState(appState.entriesState),
      tagState: updateTagState(appState.tagState),
      settingsState: updateSettingsState(appState.settingsState));
}

AppState _updateLogsTagsSingleEntryState(
  AppState appState,
  LogsState updateLogState(LogsState logsState),
  TagState updateTagState(TagState tagState),
  SingleEntryState update(SingleEntryState singleEntryState),
) {
  return appState.copyWith(
    logsState: updateLogState(appState.logsState),
    tagState: updateTagState(appState.tagState),
    singleEntryState: update(appState.singleEntryState),
  );
}

AppState _updateTagSingleEntryState(
  AppState appState,
  TagState updateTagState(TagState tagState),
  SingleEntryState update(SingleEntryState singleEntryState),
) {
  return appState.copyWith(
    tagState: updateTagState(appState.tagState),
    singleEntryState: update(appState.singleEntryState),
  );
}

class DeleteLog implements MyAction {
  //This action updates multiple states simultaneously
  final Log log;

  DeleteLog({this.log});

  @override
  AppState updateState(AppState appState) {
    LogsState updatedLogsState = appState.logsState;
    Settings settings = appState.settingsState.settings.value;
    updatedLogsState.logs.removeWhere((key, value) => key == log.id);

    List<MyEntry> deletedEntriesList = [];
    List<Tag> deletedTagsList = [];
    Map<String, MyEntry> entriesMap = Map.from(appState.entriesState.entries);
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);

    entriesMap.forEach((key, entry) {
      if (entry.logId == log.id) {
        deletedEntriesList.add(entry);
      }
    });

    entriesMap.removeWhere((key, entry) => entry.logId == log.id);

    tagsMap.forEach((key, tag) {
      if (tag.logId == log.id) {
        deletedTagsList.add(tag);
      }
    });

    tagsMap.removeWhere((key, tag) => tag.logId == log.id);

    //TODO likely need a method to reset the default to nothing, else statement for the above
    //ensures the default log is updated if the current log is default and deleted
    if (appState.settingsState.settings.value.defaultLogId == log.id && updatedLogsState.logs.isNotEmpty) {
      settings = settings.copyWith(
          defaultLogId: updatedLogsState.logs.values.firstWhere((element) => element.id != log.id).id);
    }

    Env.entriesFetcher.batchDeleteEntries(deletedEntries: deletedEntriesList);
    Env.tagFetcher.batchDeleteTags(deletedTags: deletedTagsList);
    Env.logsFetcher.deleteLog(log: log);

    return _updateLogEntriesTagSettingState(
      appState,
      (logsState) => updatedLogsState.copyWith(selectedLog: Maybe.none(),userUpdated: false),
      (entriesState) => entriesState.copyWith(entries: entriesMap),
      (tagState) => tagState.copyWith(tags: tagsMap),
      (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)),
    );
  }
}

class DeleteTagFromEntryScreen implements MyAction {
  final Tag tag;

  DeleteTagFromEntryScreen({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tagsMap = Map.from(appState.tagState.tags);
    Map<String, Tag> entryTagsMap = Map.from(appState.singleEntryState.tags);
    tagsMap.removeWhere((key, value) => key == tag.id);
    entryTagsMap.removeWhere((key, value) => key == tag.id);

    Env.tagFetcher.deleteTag(tag);

    return _updateTagSingleEntryState(
      appState,
      (tagState) => tagState.copyWith(tags: tagsMap),
      (singleEntryState) => singleEntryState.copyWith(tags: entryTagsMap, userUpdated: true),
    );
  }
}

class AddUpdateSingleEntryAndTags implements MyAction {
  //submits new entry to the entries list and the clear the singleEntryState
  final MyEntry entry;

  AddUpdateSingleEntryAndTags({this.entry});

  AppState updateState(AppState appState) {
    List<Tag> tagsToAddToDatabase = [];
    List<Tag> tagsToUpdateInDatabase = [];
    Map<String, Tag> addedUpdatedTags = Map.from(appState.singleEntryState.tags);
    Map<String, Tag> masterTagList = Map.from(appState.tagState.tags);
    Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    MyEntry updatedEntry = entry;

    Env.store.dispatch(SingleEntryProcessing());

    //update entry for state and database
    if (updatedEntry.id != null &&
        updatedEntry !=
            appState.entriesState.entries.entries
                .map((e) => e.value)
                .toList()
                .firstWhere((element) => element.id == entry.id)) {
      //update entry if id is not null and thus already exists an the entry has been modified
      Env.entriesFetcher.updateEntry(entry);
    } else if (updatedEntry.id == null) {
      //if no category has been chosen, automatically set NO_CATEGORY
      String categoryId = updatedEntry?.categoryId ?? NO_CATEGORY;
      String subcategoryId = updatedEntry?.subcategoryId;

      if (categoryId != NO_CATEGORY && categoryId != TRANSFER_FUNDS && subcategoryId == null) {
        //if the category has been chosen but not the subcategory, automatically set subcategory to "other"

        List<MyCategory> subcategories = logs[updatedEntry.logId].subcategories;

        subcategoryId = subcategories
            .firstWhere((element) => element.parentCategoryId == categoryId && element.id.contains(OTHER))
            .id;
      }

      //save new entry using the user id to help minimize chance of duplication of entry ids in the database
      Env.entriesFetcher.addEntry(updatedEntry.copyWith(
          id: '${appState.authState.user.value.id}-${Uuid().v4()}',
          categoryId: categoryId,
          subcategoryId: subcategoryId));
    }

    //update entries for total only
    entries.update(updatedEntry.id, (value) => updatedEntry, ifAbsent: () => updatedEntry);

    //update tags state
    addedUpdatedTags.forEach((key, tag) {
      if (!masterTagList.containsKey(key)) {
        //tag doesn't exist and will be added

        masterTagList.putIfAbsent(key, () => tag);
        tagsToAddToDatabase.add(tag);
      } else if (masterTagList.containsKey(key) && masterTagList[key] != tag) {
        // if the tag exists and has changed, update it
        masterTagList.update(key, (value) => tag); // update the local tag map
        tagsToUpdateInDatabase.add(tag); //updates list of tags that will be sent to database
      }
    });

    //update tags database
    Env.tagFetcher.batchAddUpdate(addedTags: tagsToAddToDatabase, updatedTags: tagsToUpdateInDatabase);

    //update logs total in state
    //logs.updateAll((key, log) => _updateLogMemberTotals(entries: entries.values.toList(), log: log));

    //update log categories and subcategories if they have changed
    logs = _updateLogCategoriesSubcategoriesFromEntry(appState: appState, logId: updatedEntry.logId, logs: logs);

    return _updateLogsTagsSingleEntryState(
      appState,
      (logsState) => logsState.copyWith(logs: logs),
      (tagState) => tagState.copyWith(tags: masterTagList),
      (singleEntryState) => SingleEntryState.initial(),
    );
  }
}

Map<String, Log> _updateLogCategoriesSubcategoriesFromEntry(
    {@required AppState appState, @required String logId, @required Map<String, Log> logs}) {
  Log log = logs[logId];
  if (appState.singleEntryState.categories != log.categories ||
      appState.singleEntryState.subcategories != log.subcategories) {
    log = log.copyWith(
        categories: appState.singleEntryState.categories, subcategories: appState.singleEntryState.subcategories);
    logs.update(log.id, (value) => log);
    //send updated log to database
    Env.logsFetcher.updateLog(log);
  }
  return logs;
}

LogTotal _updateLogMemberTotals({@required List<MyEntry> entries, @required Log log}) {
  Map<String, LogMember> logMembers = Map.from(log.logMembers);
  DateTime now = DateTime.now();

  int currentMonth = now.month;
  int currentYear = now.year;

  int lastMonth = currentMonth - 1 == 0 ? 12 : currentMonth - 1;
  int lastMonthYear = lastMonth == 12 ? currentYear - 1 : currentYear;


  int thisMonthTotalPaid = 0;
  int lastMonthTotalPaid = 0;
  int sameMonthLastYearTotalPaid = 0;
  int daysSoFar = now.day > 0 ? now.day : 1;

  entries.removeWhere((entry) => entry.logId != log.id);

  logMembers.updateAll((key, value) => value.copyWith(paid: 0, spent: 0));

  entries.forEach((entry) {
    DateTime entryDate = entry?.dateTime;
    int entryMonth = entryDate.month;
    int entryYear = entryDate.year;

    if (entryYear == currentYear && entryMonth == currentMonth) {
      entry.entryMembers.forEach((key, member) {
        int paid = member?.paid ?? 0;
        int spent = member?.spent ?? 0;
        thisMonthTotalPaid += paid;

        logMembers.update(key, (value) => value.copyWith(paid: value.paid + paid, spent: value.spent + spent));
      });
    } else if (entryYear == lastMonthYear && entryMonth == lastMonth) {
      entry.entryMembers.forEach((key, member) {
        if (member.paid != null) {
          lastMonthTotalPaid += member.paid;
        }
      });
    } else if (entryYear == currentYear - 1 && entryMonth == currentMonth) {
      entry.entryMembers.forEach((key, member) {
        if (member.paid != null) {
          sameMonthLastYearTotalPaid += member.paid;
        }
      });
    }
  });

  return LogTotal(
      logMembers: logMembers,
      thisMonthTotalPaid: thisMonthTotalPaid,
      lastMonthTotalPaid: lastMonthTotalPaid,
      sameMonthLastYearTotalPaid: sameMonthLastYearTotalPaid,
      averagePerDay: (thisMonthTotalPaid / daysSoFar).round());
}

bool _canDeleteCategory({@required String id}) {
  if (id == NO_CATEGORY || id == TRANSFER_FUNDS) {
    return false;
  }
  return true;
}

bool _canDeleteSubcategory({@required MyCategory subcategory}) {
  if (subcategory.id.contains(OTHER)) {
    return false;
  }
  return true;
}

//used by setting and log to reorder subcategories
List<MyCategory> _reorderSubcategoriesLogSetting(
    {@required MyCategory subcategory,
      @required String newParentId,
      @required String oldParentId,
      @required List<MyCategory> subsetOfSubcategories,
      @required List<MyCategory> subcategories,
    @required int newSubcategoryIndex}) {

  //NO_SUBCATEGORY cannot be altered and no subcategories may be moved to NO_CATEGORY
  if (_canReorderSubcategory(subcategory: subcategory, newParentId: newParentId)) {
    if (oldParentId == newParentId) {
      //subcategory has not moved parents
      subsetOfSubcategories.remove(subcategory);
      subsetOfSubcategories.insert(newSubcategoryIndex, subcategory);
    } else {
      //category has moved parents, organize in new list with revised parent
      subsetOfSubcategories = List.from(subcategories); //reinitialize subset list
      subsetOfSubcategories.retainWhere((subcategory) => subcategory.parentCategoryId == newParentId);
      subsetOfSubcategories.insert(newSubcategoryIndex, subcategory.copyWith(parentCategoryId: newParentId));
    }

    //remove from subcategory list
    subsetOfSubcategories.forEach((reordedSub) {
      subcategories.removeWhere((sub) => reordedSub.id == sub.id);
    });
    //reinsert in subcategory list in revised order
    subsetOfSubcategories.forEach((subcategory) {
      subcategories.add(subcategory);
    });
  }
  return subcategories;
}

//determine if the subcategory is special and connot be reOrdered
bool _canReorderSubcategory({@required MyCategory subcategory, @required String newParentId}) {
  if (newParentId == NO_CATEGORY || subcategory.id.contains(OTHER) || newParentId == TRANSFER_FUNDS) {
    return false;
  }
  return true;
}

///________________ACCOUNT ACTIONS________________

AppState _updateAccountState(
    AppState appState,
    AccountState update(AccountState accountState),
    ) {
  return appState.copyWith(accountState: update(appState.accountState));
}

class AccountUpdateFailure implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.failure());
  }
}

class AccountUpdateSubmitting implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.submitting());
  }
}

class AccountUpdateSuccess implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.success());
  }
}

class ShowHidePasswordForm implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.copyWith(showPasswordForm: !appState.accountState.showPasswordForm));
  }
}

class AccountResetState implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.resetState());
  }
}

class AccountValidateOldPassword implements MyAction {
  final String password;

  /*final String newPassword;
  final String verifyPassword*/

  AccountValidateOldPassword({this.password});

  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState, (accountState) => accountState.copyWith(isOldPasswordValid: Validators.isValidPassword(password), loginStatus: LoginStatus.updated));
  }
}

class AccountValidateNewPassword implements MyAction {
  final String newPassword;
  final String verifyPassword;

  AccountValidateNewPassword({this.newPassword, this.verifyPassword});

  @override
  AppState updateState(AppState appState) {
    bool passwordsMatch = false;

    if (newPassword == verifyPassword) {
      passwordsMatch = true;
    }

    return _updateAccountState(
        appState,
            (accountState) => accountState.copyWith(
            isNewPasswordValid: Validators.isValidPassword(newPassword), newPasswordsMatch: passwordsMatch, loginStatus: LoginStatus.updated));
  }
}

class IsUserSignedInWithEmail implements MyAction {
  final bool signedInWithEmail;

  IsUserSignedInWithEmail({this.signedInWithEmail});

  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState, (accountState) => accountState.copyWith(isUserSignedInWithEmail: signedInWithEmail));
  }
}

///__________________AUTH ACTIONS_______________________


AppState _updateAuthState(
    AppState appState,
    AuthState update(AuthState authState),
    ) {
  return appState.copyWith(authState: update(appState.authState));
}

class AuthFailure implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => AuthState.initial());
  }
}

class AuthSuccess implements MyAction {
  final User user;

  AuthSuccess({@required this.user});

  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => authState.copyWith(user: Maybe.some(user), isLoading: false));
  }
}

class SignOutState implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return AppState.initial();
  }
}

class LoadingUser implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => authState.copyWith(isLoading: true));
  }
}

class UpdateDisplayName implements MyAction {
  final String displayName;

  UpdateDisplayName({@required this.displayName});

  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => authState.copyWith(user: Maybe.some(authState.user.value.copyWith(displayName: displayName))));
  }
}

///_____________________________LOGIN REGISTER ACTIONS____________________________

AppState _updateLoginRegState(
    AppState appState,
    LoginRegState update(LoginRegState loginRegState),
    ) {
  return appState.copyWith(loginRegState: update(appState.loginRegState));
}

class LoginRegFailure implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState, (loginRegState) => loginRegState.failure());
  }
}

class LoginRegSubmitting implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState, (loginRegState) => loginRegState.submitting());
  }
}

class LoginRegSuccess implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState, (loginRegState) => loginRegState.success());
  }
}

class LoginOrCreateUser implements MyAction {
  //switches from between login or create new user
  @override
  AppState updateState(AppState appState) {
    LoginOrRegister loginOrRegister = appState.loginRegState.loginOrRegister;
    loginOrRegister = loginOrRegister == LoginOrRegister.login ? LoginOrRegister.register : LoginOrRegister.login;

    return _updateLoginRegState(appState, (loginRegState) => loginRegState.copyWith(loginOrRegister: loginOrRegister));
  }
}

class PasswordValidation implements MyAction {
  final String password;

  PasswordValidation(this.password);

  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState,
            (loginRegState) => loginRegState.updateCredentials(isPasswordValid: Validators.isValidPassword(password)));
  }
}

class EmailValidation implements MyAction {
  final String email;

  EmailValidation(this.email);

  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(
        appState, (loginRegState) => loginRegState.updateCredentials(isEmailValid: Validators.isValidEmail(email)));
  }
}

///_____________________________ENTRIES ACTIONS________________________________

AppState _updateEntriesLogTotalsState(
    AppState appState,
    LogTotalsState updateLogTotalsState(LogTotalsState logTotalsState),
    EntriesState update(EntriesState entriesState),
    ) {
  return appState.copyWith(
    logTotalsState: updateLogTotalsState(appState.logTotalsState),
    entriesState: update(appState.entriesState),
  );
}

AppState _updateEntriesState(
    AppState appState,
    EntriesState update(EntriesState entriesState),
    ) {
  return appState.copyWith(entriesState: update(appState.entriesState));
}

/*AppState _updateEntries(
  AppState appState,
  LogsState updateLogState(LogsState logsState),
  void updateInPlace(Map<String, MyEntry> entries),
) {
  Map<String, MyEntry> cloneMap = Map.from(appState.entriesState.entries);
  updateInPlace(cloneMap);
  return _updateEntriesLogsState(
    appState,
    (logsState) => updateLogState(appState.logsState),
    (entriesState) => entriesState.copyWith(entries: cloneMap),
  );
}*/

class SetEntriesLoading implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(isLoading: true));
  }
}

class SetEntriesLoaded implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(isLoading: false));
  }
}

class SetEntries implements MyAction {
  final Iterable<MyEntry> entryList;

  SetEntries({this.entryList});

  @override
  AppState updateState(AppState appState) {
    Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    Map<String, LogTotal> logTotals = LinkedHashMap();

    entries.addEntries(
      entryList.map((entry) => MapEntry(entry.id, entry)),
    );

    logs.forEach((key, log) {
      logTotals.putIfAbsent(key, () => _updateLogMemberTotals(entries: entries.values.toList(), log: log));
    });

    return _updateEntriesLogTotalsState(appState, (logTotalsState) => logTotalsState.copyWith(logTotals: logTotals),
            (entriesState) => entriesState.copyWith(entries: entries));
  }
}

class SetEntriesOrder implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateEntriesState(appState, (entriesState) => entriesState.copyWith(descending: !appState.entriesState.descending));
  }
}

class DeleteSelectedEntry implements MyAction {
  @override
  AppState updateState(AppState appState) {
    Env.store.dispatch(SingleEntryProcessing());
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    //List<MyCategory> categories = appState.singleEntryState.categories;
    Map<String, Tag> tags = appState.singleEntryState.tags;
    EntriesState updatedEntriesState = appState.entriesState;
    updatedEntriesState.entries.removeWhere((key, value) => key == entry.id);

    entry.tagIDs.forEach((tagId) {
      //updates log list of tags
      Tag tag = tags[tagId];

      //decrement use of tag for this category and log
      tag = _decrementCategoryAndLogFrequency(updatedTag: tag, categoryId: entry?.categoryId);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });

    Env.entriesFetcher.deleteEntry(entry);

    //TODO send to update all changed tags
    //Map<String, Tag> stateTags = appState.tagState.tags;

    //TODO ask Boris, is this kind of action legal, or do I need to pass the revised state back to this action?
    Env.store.dispatch(ClearEntryState());

    return _updateEntriesState(appState, (entriesState) => updatedEntriesState);
  }
}

///________________________SINGLE ENTRY ACTIONS__________________________

AppState _updateSingleEntryState(AppState appState,
    SingleEntryState update(SingleEntryState singleEntryState),) {
  return appState.copyWith(singleEntryState: update(appState.singleEntryState));
}

class UpdateSingleEntryState implements MyAction {
  final Maybe<MyEntry> selectedEntry;
  final Maybe<Tag> selectedTag;
  final Map<String, Tag> tags;
  final List<MyCategory> logCategoryList;
  final bool savingEntry;

  UpdateSingleEntryState({this.selectedEntry, this.selectedTag, this.tags, this.logCategoryList, this.savingEntry});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
              selectedEntry: selectedEntry,
              selectedTag: selectedTag,
              tags: tags,
              categories: logCategoryList,
              processing: savingEntry,
            ));
  }
}

/*SET OR SELECT ENTRY*/

class SetNewSelectedEntry implements MyAction {
  //sets new entry and resets all entry data not yet available
  final String logId;
  final String memberId;

  SetNewSelectedEntry({this.logId, this.memberId});

  @override
  AppState updateState(AppState appState) {
    //TODO can probably abstract away to either settings model or to settings actions, i think model would be better, only update if needed

    MyEntry entry = MyEntry();
    //if a log is not passed to the action it is assumed to have been triggered from the FAB and creates and entry for the default log

    Log log = appState.logsState
        .logs[logId ?? appState.settingsState.settings?.value?.defaultLogId ?? appState.logsState.logs.keys.first];
    Map<String, Tag> tags = Map.from(appState.tagState.tags)
      ..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> members = _setMembersList(log: log, memberId: memberId);

    entry = entry.copyWith(
        logId: log.id,
        currency: log.currency,
        dateTime: DateTime.now(),
        tagIDs: [],
        entryMembers: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry),
              selectedTag: Maybe.some(Tag()),
              tags: tags,
              categories: List.from(log.categories),
              subcategories: List.from(log.subcategories),
              processing: false,
              commentFocusNode: Maybe.some(FocusNode()),
              tagFocusNode: Maybe.some(FocusNode()),));
  }
}

class SelectEntry implements MyAction {
  //sets selected entry and resets all entry data not yet available
  final String entryId;

  SelectEntry({@required this.entryId});

  @override
  AppState updateState(AppState appState) {
    MyEntry entry = appState.entriesState.entries[entryId];
    Log log = appState.logsState.logs.values.firstWhere((element) => element.id == entry.logId);
    Map<String, Tag> tags = Map.from(appState.tagState.tags)
      ..removeWhere((key, value) => value.logId != log.id);
    Map<String, EntryMember> entryMembers = Map.from(entry.entryMembers);
    entryMembers.updateAll((key, value) =>
        value.copyWith(
          payingController: TextEditingController(text: formattedAmount(value: value?.paid)),
          spendingController: TextEditingController(text: formattedAmount(value: value?.spent)),
          payingFocusNode: FocusNode(),
          spendingFocusNode: FocusNode(),
        ));

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: entryMembers)),
              selectedTag: Maybe.some(Tag()),
              tags: tags,
              categories: List.from(log.categories),
              subcategories: List.from(log.subcategories),
              processing: false,
              commentFocusNode: Maybe.some(FocusNode()),
              tagFocusNode: Maybe.some(FocusNode()),
            ));
  }
}

/*ADD UPDATE DELETE ENTRY SECTION*/

class SingleEntryProcessing implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (singleEntryState) => singleEntryState.copyWith(processing: true));
  }
}

class ClearEntryState implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(appState, (entryState) => SingleEntryState.initial());
  }
}

/*CHANGE ENTRY VALUES*/

class UpdateEntryCurrency implements MyAction {
  final String currency;

  UpdateEntryCurrency({@required this.currency});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(currency: currency)),
                userUpdated: true));
  }
}

class UpdateEntryComment implements MyAction {
  final String comment;

  UpdateEntryComment({@required this.comment});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(comment: comment)),
                userUpdated: true));
  }
}

class UpdateEntryDateTime implements MyAction {
  final DateTime dateTime;

  UpdateEntryDateTime({this.dateTime});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(dateTime: dateTime)),
                userUpdated: true));
  }
}

class UpdateEntrySubcategory implements MyAction {
  final String subcategory;

  UpdateEntrySubcategory({this.subcategory});

  @override
  AppState updateState(AppState appState) {
    return _updateSingleEntryState(
        appState,
            (entryState) =>
            entryState.copyWith(
                selectedEntry: Maybe.some(entryState.selectedEntry.value.copyWith(subcategoryId: subcategory)),
                userUpdated: true));
  }
}

/*class ChangeEntryLog implements Action {
  final Log log;

  ChangeEntryLog({@required this.log});

  @override
  AppState updateState(AppState appState) {
    if (log.id == appState.singleEntryState.selectedEntry.value.logId) {
      return _updateSingleEntryState(appState, (singleEntryState) => singleEntryState);
    } else {
      Map<String, Tag> tags = Map.from(appState.tagState.tags)
        ..removeWhere((key, value) => value.logId != log.id); //log changes tags change
      Map<String, Member> members = _setMembersList(log: log); //log changes members change
      //TODO changing the entry log is more complicated than this, first you actually need to update the log it came from, then the log its going to

      return _updateSingleEntryState(
          appState,
          (singleEntryState) => singleEntryState.copyWith(
              tags: tags,
              selectedTag: Maybe.none(),
              logCategoryList: log.categories,
              selectedEntry: Maybe.some(
                singleEntryState.selectedEntry.value
                    .changeLog(log: log)
                    .copyWith(tagIDs: List<String>(), entryMembers: members),
              )));
    }
  }
}*/

class UpdateEntryCategory implements MyAction {
  final String newCategory;

  UpdateEntryCategory({@required this.newCategory});

  @override
  AppState updateState(AppState appState) {
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    String oldCategoryId = entry.categoryId;

    entry.tagIDs.forEach((tagId) {
      Tag tag = tags[tagId];

      //uses NO_CATEGORY for increment and decrement default as the actions utilize NO_CATEGORY until it is confirmed by the user
      tag = _decrementCategoryFrequency(categoryId: oldCategoryId ?? NO_CATEGORY, updatedTag: tag);

      tag = _incrementCategoryFrequency(categoryId: newCategory ?? NO_CATEGORY, updatedTag: tag);

      tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
    });

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              tags: tags,
              selectedEntry: Maybe.some(entry.changeCategories(category: newCategory ?? NO_CATEGORY)),
              userUpdated: true,
            ));
  }
}

class ReorderCategoriesFromEntryScreen implements MyAction {
  final int newIndex;
  final int oldIndex;

  ReorderCategoriesFromEntryScreen({@required this.newIndex, @required this.oldIndex});

  AppState updateState(AppState appState) {
    List<MyCategory> categories = List.from(appState.singleEntryState.categories);
    int categoryNewIndex = newIndex;

    if (newIndex > categories.length) categoryNewIndex = categories.length;
    if (oldIndex < newIndex) categoryNewIndex--;

    MyCategory category = categories[oldIndex];
    categories.remove(category);
    categories.insert(categoryNewIndex, category);

    return _updateSingleEntryState(
      appState,
          (singleEntryState) => singleEntryState.copyWith(categories: categories, userUpdated: true),
    );
  }
}

class ReorderSubcategoriesFromEntryScreen implements MyAction {
  final List<MyCategory> reorderedSubcategories;
  final int newIndex;
  final int oldIndex;

  ReorderSubcategoriesFromEntryScreen(
      {@required this.newIndex, @required this.oldIndex, @required this.reorderedSubcategories});

  AppState updateState(AppState appState) {
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    int subcategoryNexIndex = newIndex;

    if (subcategories.length > 1) {
      if (newIndex > reorderedSubcategories.length) subcategoryNexIndex = reorderedSubcategories.length;
      if (oldIndex < subcategoryNexIndex) subcategoryNexIndex--;

      MyCategory category = reorderedSubcategories[oldIndex];
      reorderedSubcategories.remove(category);
      reorderedSubcategories.insert(newIndex, category);

      reorderedSubcategories.forEach((reordedSub) {
        subcategories.removeWhere((sub) => reordedSub.id == sub.id);
      });
      reorderedSubcategories.forEach((subcategory) {
        subcategories.add(subcategory);
      });
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) => singleEntryState.copyWith(subcategories: subcategories, userUpdated: true),
    );
  }
}

class AddEditCategoryFromEntryScreen implements MyAction {
  final MyCategory category;

  AddEditCategoryFromEntryScreen({@required this.category});

  AppState updateState(AppState appState) {
    List<MyCategory> categories = List.from(appState.singleEntryState.categories);
    if (category.id == null) {
      categories.add(category.copyWith(id: Uuid().v4()));
    } else {
      categories[categories.indexWhere((entry) => entry.id == category.id)] = category;
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) => singleEntryState.copyWith(categories: categories, userUpdated: true),
    );
  }
}

class DeleteCategoryFromEntryScreen implements MyAction {
  final MyCategory category;

  DeleteCategoryFromEntryScreen({@required this.category});

  AppState updateState(AppState appState) {
    List<MyCategory> categories = List.from(appState.singleEntryState.categories);
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    bool canDeleteCategory = _canDeleteCategory(id: category.id);

    //remove category and its subcategories if the category is not "no category"
    if (canDeleteCategory) {
      categories.removeWhere((e) => e.id == category.id);
      subcategories.removeWhere((e) => e.parentCategoryId == category.id);
    }
    if (category.id == entry.categoryId) {
      //if we deleted the category used by the entry, reset the entry to no category or subcategory
      entry = MyEntry(
        id: entry.id,
        logId: entry.logId,
        currency: entry.currency,
        amount: entry.amount,
        comment: entry.comment,
        dateTime: entry.dateTime,
        tagIDs: entry.tagIDs,
        entryMembers: entry.entryMembers,
      );
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) =>
          singleEntryState.copyWith(
              categories: categories,
              subcategories: subcategories,
              selectedEntry: Maybe.some(entry),
              userUpdated: false),
    );
  }
}

class AddEditSubcategoryFromEntryScreen implements MyAction {
  final MyCategory subcategory;

  AddEditSubcategoryFromEntryScreen({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    String previousParentId = entry.categoryId;

    if (subcategory.id == null) {
      //add new subcategory
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    } else {
      //edit subcategory
      subcategories[subcategories.indexWhere((entry) => entry.id == subcategory.id)] = subcategory;

      //if the parent category of the subcategory was changed and thus the entry category changed, update the tag frequency
      if (previousParentId != subcategory.parentCategoryId && entry.subcategoryId == subcategory.id) {
        entry.tagIDs.forEach((tagId) {
          Tag tag = tags[tagId];

          tag = _decrementCategoryFrequency(categoryId: previousParentId, updatedTag: tag);

          tag = _incrementCategoryFrequency(categoryId: subcategory.parentCategoryId, updatedTag: tag);

          tags.update(tag.id, (value) => tag, ifAbsent: () => tag);
        });
        entry = entry.copyWith(categoryId: subcategory.parentCategoryId);
      }
    }

    //update the subcategory as well as the category if the parent has changed
    return _updateSingleEntryState(
      appState,
          (singleEntryState) =>
          singleEntryState.copyWith(
              subcategories: subcategories, tags: tags, selectedEntry: Maybe.some(entry), userUpdated: true),
    );
  }
}

class DeleteSubcategoryFromEntryScreen implements MyAction {
  final MyCategory subcategory;

  DeleteSubcategoryFromEntryScreen({@required this.subcategory});

  AppState updateState(AppState appState) {
    List<MyCategory> subcategories = List.from(appState.singleEntryState.subcategories);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    bool canDeleteSubcategory = _canDeleteSubcategory(subcategory: subcategory);

    if (canDeleteSubcategory) {
      subcategories.removeWhere((e) => e.id == subcategory.id);
      if (subcategory.id == entry.subcategoryId) {
        //TODO this should auto select the "other" subcategory
        //entry = entry.copyWith(subcategoryId: NO_SUBCATEGORY);
      }
    }

    return _updateSingleEntryState(
      appState,
          (singleEntryState) =>
          singleEntryState.copyWith(subcategories: subcategories, selectedEntry: Maybe.some(entry), userUpdated: true),
    );
  }
}

//TODO this should be combined with ClearEntryState()
class UpdateLogCategoriesSubcategoriesOnEntryScreenClose implements MyAction {
  @override
  AppState updateState(AppState appState) {
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    logs = _updateLogCategoriesSubcategoriesFromEntry(
        appState: appState, logId: appState.singleEntryState.selectedEntry.value.logId, logs: logs);

    return _updateLogState(appState, (logsState) => logsState.copyWith(logs: logs));
  }
}

/*MEMBER ACTIONS*/

class UpdateMemberPaidAmount implements MyAction {
  final int paidValue;
  final EntryMember member;

  UpdateMemberPaidAmount({@required this.paidValue, @required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    int amount = 0;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //update amount paid by individual member
    member = member.copyWith(paid: paidValue);
    members.update(member.uid, (value) => member);

    //update total amount paid by all members
    members.forEach((key, value) {
      if (value.paid != null && value.paying) {
        amount = amount + value.paid;
      }
    });

    members = _divideSpendingEvenly(amount: amount, members: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(amount: amount, entryMembers: members)),
              userUpdated: true,
            ));
  }
}

class UpdateMemberSpentAmount implements MyAction {
  final int spentValue;
  final EntryMember member;

  UpdateMemberSpentAmount({@required this.spentValue, @required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //update amount spent by individual member
    member = member.copyWith(spent: spentValue);
    members.update(member.uid, (value) => member);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members)),
              userUpdated: true,
            ));
  }
}

class ToggleMemberPaying implements MyAction {
  final EntryMember member;

  ToggleMemberPaying({@required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;
    int amount = 0;

    //count number of members paying
    int membersPaying = 0;
    members.forEach((key, value) {
      if (value.paying == true) {
        membersPaying += 1;
      }
    });

    //if the selected payer is the last, they cannot be removed
    if (membersPaying > 1 || member.paying == false) {
      //toggles member paying or not
      FocusNode payingFocusNode = member.payingFocusNode;

      //if member is now paying, focus on their paid amount variable
      if (member.paying == false) {
        payingFocusNode.requestFocus();
      } else if (payingFocusNode.hasFocus) {
        payingFocusNode.unfocus();
      }

      member = member.copyWith(paying: !member.paying, payingFocusNode: payingFocusNode);

      members.update(member.uid, (value) => member);
    }

    members.forEach((key, value) {
      if (value.paid != null && value.paying) {
        amount = amount + value.paid;
      }
    });

    //redistributes expense based on revision of who is paying
    members = _divideSpendingEvenly(amount: amount, members: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members, amount: amount)),
              userUpdated: true,
            ));
  }
}

class ToggleMemberSpending implements MyAction {
  final EntryMember member;

  ToggleMemberSpending({@required this.member});

  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> members = Map.from(entry.entryMembers);
    EntryMember member = this.member;

    //toggles member spending or not
    int membersSpending = 0;
    members.forEach((key, value) {
      if (value.spending == true) {
        membersSpending += 1;
      }
    });

    //cannot uncheck member if they are the last spending
    if (membersSpending > 1 || member.spending == false) {
      member = member.copyWith(spending: !member.spending, spent: 0);
      members.update(member.uid, (value) => member);
    }

    //redistributes expense based on revision of who is paying
    members = _divideSpendingEvenly(amount: entry.amount, members: members);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
              selectedEntry: Maybe.some(entry.copyWith(entryMembers: members)),
              userUpdated: true,
            ));
  }
}

/*TAGS SECTION*/

class AddUpdateTagFromEntryScreen implements MyAction {
  final Tag tag;

  AddUpdateTagFromEntryScreen({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag addedUpdatedTag = tag;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Tag existingTag;

    for (Tag value in tags.values.toList()) {
      if (value.name.toLowerCase() == tag.name.toLowerCase()) {
        existingTag = value;
        break;
      }
    }

    if (addedUpdatedTag.id == null) {
      if (existingTag == null) {
        //save new tag using the user id to help minimize chance of duplication of entry ids in the database
        addedUpdatedTag = addedUpdatedTag.copyWith(
          id: '${Uuid().v4()}-${appState.authState.user.value.id}',
          logId: entry.logId,
          tagLogFrequency: 1,
          memberList: entry.entryMembers.keys.toList(),
        );
      } else {
        //the tag already exists in the log, add to the entry and increment the log frequency
        addedUpdatedTag = existingTag.incrementTagLogFrequency();
      }

      entry.tagIDs.add(addedUpdatedTag.id);

      addedUpdatedTag =
          _incrementCategoryFrequency(updatedTag: addedUpdatedTag, categoryId: entry.categoryId ?? NO_CATEGORY);
      print('tag: $addedUpdatedTag');
    }

    //updates existing tag or add it
    tags.update(addedUpdatedTag.id, (value) => addedUpdatedTag, ifAbsent: () => addedUpdatedTag);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
                selectedEntry: Maybe.some(entry), selectedTag: Maybe.some(Tag()), tags: tags, userUpdated: true));
  }
}

class SelectDeselectEntryTag implements MyAction {
  final Tag tag;

  SelectDeselectEntryTag({@required this.tag});

  @override
  AppState updateState(AppState appState) {
    Tag selectedDeselectedTag = tag;
    Map<String, Tag> tags = Map.from(appState.singleEntryState.tags);
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    List<String> entryTagIds = entry.tagIDs;
    bool entryHasTag = false;

    //determines if the tag is in the entry or in another list
    entryTagIds.forEach((element) {
      if (element == tag.id) {
        entryHasTag = true;
      }
    });

    if (entryHasTag) {
      //remove tag from entry if present

      selectedDeselectedTag = _decrementCategoryAndLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry?.categoryId ?? NO_CATEGORY);

      //remove the tag from the entry tag list
      entryTagIds.remove(tag.id);
    } else {
      //add tag to entry if not present

      //increment use of tag for this category
      selectedDeselectedTag = _incrementCategoryAndLogFrequency(
          updatedTag: selectedDeselectedTag, categoryId: entry?.categoryId ?? NO_CATEGORY);

      //remove the tag from the entry tag list
      entryTagIds.add(tag.id);
    }

    tags.update(selectedDeselectedTag.id, (value) => selectedDeselectedTag, ifAbsent: () => selectedDeselectedTag);

    return _updateSingleEntryState(
        appState,
            (singleEntryState) =>
            singleEntryState.copyWith(
                selectedEntry: Maybe.some(entry.copyWith(tagIDs: entryTagIds)), tags: tags, userUpdated: true));
  }
}

class EntryNextFocus implements MyAction {
  @override
  AppState updateState(AppState appState) {
    MyEntry entry = appState.singleEntryState.selectedEntry.value;
    Map<String, EntryMember> memberMap = Map.from(entry.entryMembers);
    List<EntryMember> memberList = memberMap.values.toList();
    int memberFocusIndex;
    bool membersHaveFocus = false;
    FocusNode commentFocusNode = appState.singleEntryState.commentFocusNode.value;
    FocusNode tagFocusNode = appState.singleEntryState.tagFocusNode.value;

    for (int i = 0; i < memberList.length; i++) {
      if (memberList[i].payingFocusNode.hasFocus) {
        //remove focus from current focused member
        memberFocusIndex = i;
        FocusNode payingFocusNode = memberList[i].payingFocusNode;
        payingFocusNode.unfocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(payingFocusNode: payingFocusNode));
      } else if (memberFocusIndex != null && i > memberFocusIndex && memberList[i].paying == true) {
        //focus on next paying member if there is one
        FocusNode payingFocusNode = memberList[i].payingFocusNode;
        payingFocusNode.requestFocus();
        memberMap.update(memberList[i].uid, (value) => memberList[i].copyWith(payingFocusNode: payingFocusNode));
        membersHaveFocus = true;
        break;
      }
    }

    if (!membersHaveFocus) {
      if (!commentFocusNode.hasFocus) {
        commentFocusNode.requestFocus();
      } else {
        commentFocusNode.unfocus();
        tagFocusNode.requestFocus();
      }
    }


    return _updateSingleEntryState(appState, (singleEntryState) =>
        singleEntryState.copyWith(selectedEntry: Maybe.some(entry.copyWith(entryMembers: memberMap)),
          commentFocusNode: Maybe.some(commentFocusNode),
          tagFocusNode: Maybe.some(tagFocusNode),));
  }
}


Tag _incrementCategoryFrequency({@required String categoryId, @required Tag updatedTag}) {
  Map<String, int> tagCategoryFrequency = Map.from(updatedTag.tagCategoryFrequency);

  //adds frequency to tag for the category if present, adds it otherwise
  tagCategoryFrequency.update(categoryId, (value) => value + 1, ifAbsent: () => 1);
  updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);

  return updatedTag;
}

Tag _incrementCategoryAndLogFrequency({@required Tag updatedTag, String categoryId}) {
  //increment use of tag for this category

  updatedTag = _incrementCategoryFrequency(categoryId: categoryId, updatedTag: updatedTag);

  //increment use of tag for this log
  updatedTag = updatedTag.incrementTagLogFrequency();

  return updatedTag;
}

Tag _decrementCategoryFrequency({@required String categoryId, @required Tag updatedTag}) {
  Map<String, int> tagCategoryFrequency = Map.from(updatedTag.tagCategoryFrequency);

  //subtracts frequency to tag for the category if present, adds it otherwise
  tagCategoryFrequency.update(categoryId, (value) => value - 1, ifAbsent: () => 0);
  tagCategoryFrequency.removeWhere(
          (key, value) => value < 1); //removes category frequencies where the tags is no longer used by any entries

  updatedTag = updatedTag.copyWith(tagCategoryFrequency: tagCategoryFrequency);

  return updatedTag;
}

Tag _decrementCategoryAndLogFrequency({@required Tag updatedTag, @required String categoryId}) {
  //decrement use of tag for this category

  updatedTag = _decrementCategoryFrequency(categoryId: categoryId, updatedTag: updatedTag);

  //decrement use of tag for this log
  updatedTag = updatedTag.decrementTagLogFrequency();

  return updatedTag;
}

Map<String, EntryMember> _divideSpendingEvenly({@required int amount, @required Map<String, EntryMember> members}) {
  Map<String, EntryMember> entryMembers = Map.from(members);
  int membersSpending = 0;
  int remainder = 0;

  //if members are spending, add the to the divisor
  entryMembers.forEach((key, value) {
    if (value.spending == true) {
      membersSpending += 1;
    }
  });

  if (amount != null) {
    remainder = amount.remainder(membersSpending);
  }

  //TODO need to handle the remainder, could possibly do this by dividing the initial value by 3, then subtracting the value each time until the last member is reached
  //re-adjust who spent based on the new total amount
  entryMembers.forEach((key, value) {
    int memberSpentAmount = 0;
    if (value.spending == true && amount != null && amount != 0) {
      memberSpentAmount = (amount / membersSpending).truncate();

      if (remainder > 0) {
        memberSpentAmount += 1;
        remainder--;
      }
    }

    value.spendingController.value = TextEditingValue(text: formattedAmount(value: memberSpentAmount));
    entryMembers.update(key, (value) => value.copyWith(spent: memberSpentAmount));
  });

  return entryMembers;
}

Map<String, EntryMember> _setMembersList({@required Log log, @required String memberId}) {
  //adds the log members to the entry member list when creating a new entry of changing logs

  Map<String, EntryMember> members = {};

  log.logMembers.forEach((key, value) {
    members.putIfAbsent(
        key,
            () =>
            EntryMember(
              uid: value.uid,
              order: value.order,
              paying: value.role == OWNER ? true : false,
              payingController: TextEditingController(),
              spendingController: TextEditingController(),
              payingFocusNode: FocusNode(),
              spendingFocusNode: FocusNode(),
            ));
  });

  //sets the selected user as paying unless the action is triggered from the FAB
  members.updateAll((key, value) => value.copyWith(paying: key == memberId ? true : false));

  return members;
}

///______________________________________LOG ACTIONS__________________________________________

AppState _updateLogState(
    AppState appState,
    LogsState update(LogsState logsState),
    ) {
  return appState.copyWith(logsState: update(appState.logsState));
}

AppState _updateLogs(
    AppState appState,
    void updateInPlace(Map<String, Log> logs),
    ) {
  Map<String, Log> cloneMap = Map.from(appState.logsState.logs);
  updateInPlace(cloneMap);
  return _updateLogState(appState, (logsState) => logsState.copyWith(logs: cloneMap));
}

class SetLogsLoading implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(isLoading: true));
  }
}

class SetLogsLoaded implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(isLoading: false));
  }
}

class SetNewLog implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(Log(currency: 'CAD'))));
  }
}

class UpdateSelectedLog implements MyAction {
  final Log log;

  UpdateSelectedLog({this.log});

  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log), userUpdated: true));
  }
}

class NewLogSetCategories implements MyAction {
  final Log log;
  final bool userUpdated;

  NewLogSetCategories({@required this.log, this.userUpdated = false});

  @override
  AppState updateState(AppState appState) {
    Log newLog = appState.logsState.selectedLog.value;

    return _updateLogState(
      appState,
          (logsState) => logsState.copyWith(
        selectedLog: Maybe.some(
          newLog.copyWith(
            categories: List.from(log.categories),
            subcategories: List.from(log.subcategories),
          ),
        ),
        userUpdated: userUpdated,
      ),
    );
  }
}

class SelectLog implements MyAction {
  final String logId;

  SelectLog({this.logId});

  @override
  AppState updateState(AppState appState) {
    List<bool> expandedCategories = [];
    appState.logsState.logs[logId].categories.forEach((element) {
      expandedCategories.add(false);
    });

    return _updateLogState(
        appState,
            (logsState) =>
            logsState.copyWith(selectedLog: Maybe.some(logsState.logs[logId]), expandedCategories: expandedCategories));
  }
}

class ClearSelectedLog implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.none()));
  }
}

class SetLogs implements MyAction {
  final Iterable<Log> logList;

  SetLogs({this.logList});

  @override
  AppState updateState(AppState appState) {
    return _updateLogs(appState, (logs) {
      logs.addEntries(
        logList.map(
              (log) => MapEntry(log.id, log),
        ),
      );
    });
  }
}

class CanReorder implements MyAction {
  final bool save;

  CanReorder({this.save = false});

  @override
  AppState updateState(AppState appState) {
    bool reorder = appState.logsState.reorder;

    if (reorder && save) {
      //app is in reorder state and user wishes to save
      appState.logsState.logs.forEach((key, log) {
        Env.logsFetcher.updateLog(log);
      });
    } else if (reorder && !save) {
      //app is in reorder state and user does not wish to save, reload previous logs
      Env.logsFetcher.loadLogs();
    }

    return _updateLogState(appState, (logsState) => logsState.copyWith(reorder: !reorder));
  }
}

class ReorderLog implements MyAction {
  final int oldIndex;
  final int newIndex;
  final List<Log> logs;

  ReorderLog({this.oldIndex, this.newIndex, this.logs});

  @override
  AppState updateState(AppState appState) {
    Map<String, Log> logsMap = Map.from(appState.logsState.logs);
    List<Log> organizedLogs = logs;

    Log movedLog = organizedLogs.removeAt(oldIndex);
    organizedLogs.insert(newIndex, movedLog);

    organizedLogs.forEach((log) {
      logsMap[log.id] = log.copyWith(order: organizedLogs.indexOf(log));
    });

    return _updateLogState(appState, (logsState) => logsState.copyWith(logs: logsMap));
  }
}

class AddUpdateLog implements MyAction {
  AppState updateState(AppState appState) {
    Log addedUpdatedLog = appState.logsState.selectedLog.value;
    Map<String, Log> logs = Map.from(appState.logsState.logs);
    // Map<String, MyEntry> entries = Map.from(appState.entriesState.entries);

    //check is the log currently exists
    if (addedUpdatedLog.id != null && appState.logsState.logs.containsKey(addedUpdatedLog.id)) {
      //update an existing log
      Env.logsFetcher.updateLog(addedUpdatedLog);

      //if there are new log members, add them to all transaction
      if (logs[addedUpdatedLog.id].logMembers.length != addedUpdatedLog.logMembers.length) {
        List<MyEntry> entries =
        appState.entriesState.entries.values.where((entry) => entry.logId == addedUpdatedLog.id).toList();
        Env.entriesFetcher.batchUpdateEntries(entries: entries, logMembers: addedUpdatedLog.logMembers);
      }

      logs.update(
        addedUpdatedLog.id,
            (value) => addedUpdatedLog,
        ifAbsent: () => addedUpdatedLog,
      );
    } else {
      //create a new log, does not save locally to state as there is no id yet
      Map<String, LogMember> members = {};
      String uid = appState.authState.user.value.id;
      int order = 0;

      if (logs.length > 0) {
        logs.forEach((key, log) {
          if (log.order > order) {
            order = log.order;
          }
        });
        order++;
      }

      members.putIfAbsent(
          uid, () => LogMember(uid: uid, role: OWNER, name: appState.authState.user.value.displayName, order: 0));

      addedUpdatedLog = addedUpdatedLog.copyWith(
        uid: uid,
        logMembers: members,
        order: order,
      );

      Env.logsFetcher.addLog(addedUpdatedLog);
    }

    return _updateLogState(
        appState, (logsState) => logsState.copyWith(selectedLog: Maybe.none(), logs: logs, userUpdated: false));
  }
}

class AddMemberToSelectedLog implements MyAction {
  final String uid;
  final String name;

  AddMemberToSelectedLog({this.uid, this.name});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    Map<String, LogMember> logMembers = Map.from(log.logMembers);
    //orders added log member as next in the order
    logMembers.putIfAbsent(uid, () => LogMember(uid: uid, name: name, order: logMembers.length));

    log = log.copyWith(logMembers: logMembers);

    return _updateLogState(
        appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log), userUpdated: true));
  }
}

//used for name changes
class UpdateLogMember implements MyAction {
  @override
  AppState updateState(AppState appState) {
    User user = appState.authState.user.value;
    String uid = user.id;
    String displayName = user.displayName;
    Map<String, Log> logs = Map.from(appState.logsState.logs);

    appState.logsState.logs.forEach((key, log) {
      Map<String, LogMember> logMembers = Map.from(log.logMembers);
      print('logMembers: $logMembers');
      logMembers.update(uid, (logMember) => logMember.copyWith(name: displayName));
      logs.update(key, (value) => value.copyWith(logMembers: logMembers)); //updates the log locally
      Env.logsFetcher.updateLog(logs[key]); //update log in the database
    });

    return _updateLogState(appState, (logsState) => logsState.copyWith(logs: logs));
  }
}

class AddEditCategoryFromLog implements MyAction {
  final MyCategory category;

  AddEditCategoryFromLog({@required this.category});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> categories = List.from(log.categories);
    List<MyCategory> subcategories = List.from(log.subcategories);
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    MyCategory updatedCategory = category;

    if (updatedCategory?.id != null) {
      //category exists, update category
      categories[categories.indexWhere((e) => e.id == updatedCategory.id)] = updatedCategory;
    } else {
      //category does not exists, create category
      updatedCategory = updatedCategory.copyWith(id: Uuid().v4());
      categories.add(updatedCategory);
      expandedCategories.add(false);

      //every new category automatically gets a new subcategory "other"
      MyCategory otherSubcategory =
      MyCategory(parentCategoryId: updatedCategory.id, id: 'other${Uuid().v4()}', name: 'Other', emojiChar: '🤷');

      subcategories.add(otherSubcategory);
    }

    log = log.copyWith(categories: categories, subcategories: subcategories);

    return _updateLogState(appState,
            (logsState) => logsState.copyWith(selectedLog: Maybe.some(log), expandedCategories: expandedCategories));
  }
}

class DeleteCategoryFromLog implements MyAction {
  final MyCategory category;

  DeleteCategoryFromLog({@required this.category});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> categories = List.from(log.categories);
    List<MyCategory> subcategories = List.from(log.subcategories);
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    bool canDeleteCategory = _canDeleteCategory(id: category.id);

    //remove category and its subcategories if the category is not "no category"
    if (canDeleteCategory) {
      int indexOfCategory = categories.indexWhere((element) => element.id == category.id);
      categories.removeAt(indexOfCategory);
      subcategories.removeWhere((e) => e.parentCategoryId == category.id);
      expandedCategories.removeAt(indexOfCategory);
    }

    log = log.copyWith(subcategories: subcategories, categories: categories);

    return _updateLogState(appState,
            (logsState) => logsState.copyWith(selectedLog: Maybe.some(log), expandedCategories: expandedCategories));
  }
}

class AddEditSubcategoryFromLog implements MyAction {
  final MyCategory subcategory;

  AddEditSubcategoryFromLog({@required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> subcategories = List.from(log.subcategories);

    if (subcategory?.id != null) {
      //category exists, update category
      subcategories[subcategories.indexWhere((e) => e.id == subcategory.id)] = subcategory;
    } else {
      //category does not exists, create category
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    }

    log = log.copyWith(subcategories: subcategories);

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

class DeleteSubcategoryFromLog implements MyAction {
  final MyCategory subcategory;

  DeleteSubcategoryFromLog({@required this.subcategory});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    List<MyCategory> subcategories = List.from(log.subcategories);
    bool canDeleteSubcategory = _canDeleteSubcategory(subcategory: subcategory);

    if (canDeleteSubcategory) {
      subcategories.removeWhere((e) => e.id == subcategory.id);
      log = log.copyWith(subcategories: subcategories);
    }

    return _updateLogState(appState, (logsState) => logsState.copyWith(selectedLog: Maybe.some(log)));
  }
}

class ExpandCollapseLogCategory implements MyAction {
  final int index;

  ExpandCollapseLogCategory({@required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return _updateLogState(appState, (logsState) => logsState.copyWith(expandedCategories: expandedCategories));
  }
}

class ReorderCategoryFromLogScreen implements MyAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;

  ReorderCategoryFromLogScreen({@required this.oldCategoryIndex, @required this.newCategoryIndex});

  AppState updateState(AppState appState) {
    //reorder categories
    List<MyCategory> categories = List.from(appState.logsState.selectedLog.value.categories);
    //TODO this is the same as the settings method, remove duplication
    MyCategory movedCategory = categories.removeAt(oldCategoryIndex);
    categories.insert(newCategoryIndex, movedCategory);

    //reorder expanded list
    List<bool> expandedCategories = List.from(appState.logsState.expandedCategories);
    //TODO this is the same as the settings method, remove duplication on this as well
    bool movedExpansion = expandedCategories.removeAt(oldCategoryIndex);
    expandedCategories.insert(newCategoryIndex, movedExpansion);

    return _updateLogState(
        appState,
            (logsState) => logsState.copyWith(
            selectedLog: Maybe.some(appState.logsState.selectedLog.value.copyWith(categories: categories)),
            expandedCategories: expandedCategories));
  }
}

class ReorderSubcategoryFromLogScreen implements MyAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;
  final int oldSubcategoryIndex;
  final int newSubcategoryIndex;

  ReorderSubcategoryFromLogScreen(
      {@required this.oldCategoryIndex,
        @required this.newCategoryIndex,
        @required this.oldSubcategoryIndex,
        @required this.newSubcategoryIndex});

  AppState updateState(AppState appState) {
    Log log = appState.logsState.selectedLog.value;
    String oldParentId = log.categories[oldCategoryIndex].id;
    String newParentId = log.categories[newCategoryIndex].id;
    List<MyCategory> subcategories = List.from(log.subcategories);
    List<MyCategory> subsetOfSubcategories = List.from(subcategories);
    subsetOfSubcategories
        .retainWhere((subcategory) => subcategory.parentCategoryId == oldParentId); //get initial subset
    MyCategory subcategory = subsetOfSubcategories[oldSubcategoryIndex];

    subcategories = _reorderSubcategoriesLogSetting(
        newSubcategoryIndex: newSubcategoryIndex,
        subcategory: subcategory,
        newParentId: newParentId,
        oldParentId: oldParentId,
        subsetOfSubcategories: subsetOfSubcategories,
        subcategories: subcategories);

    return _updateLogState(
        appState,
            (logsState) => logsState.copyWith(
            selectedLog: Maybe.some(appState.logsState.selectedLog.value.copyWith(subcategories: subcategories))));
  }
}

///_______________________________TAG ACTIONS_____________________________________

AppState _updateTagState(
    AppState appState,
    TagState update(TagState tagState),
    ) {
  return appState.copyWith(tagState: update(appState.tagState));
}

AppState _updateTags(
    AppState appState,
    void updateInPlace(Map<String, Tag> tags),
    ) {
  Map<String, Tag> cloneMap = Map.from(appState.tagState.tags);
  updateInPlace(cloneMap);
  return _updateTagState(appState, (tagState) => tagState.copyWith(tags: cloneMap));
}

class SetTagsLoading implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateTagState(appState, (tagState) => tagState.copyWith(isLoading: true));
  }
}

class SetTagsLoaded implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateTagState(appState, (tagState) => tagState.copyWith(isLoading: false));
  }
}

class SetTags implements MyAction {
  final Iterable<Tag> tagList;

  SetTags({this.tagList});

  @override
  AppState updateState(AppState appState) {
    return _updateTags(appState, (tag) {
      tag.addEntries(
        tagList.map(
              (tag) => MapEntry(tag.id, tag),
        ),
      );
    });
  }
}

///_____________________________SETTINGS ACTIONS_______________________________________

AppState _updateSettingsState(AppState appState,
    SettingsState update(SettingsState settingsState),) {
  return appState.copyWith(settingsState: update(appState.settingsState));
}

class UpdateSettings implements MyAction {
  final Maybe<Settings> settings;

  UpdateSettings({@required this.settings});

  @override
  AppState updateState(AppState appState) {
    Env.settingsFetcher.writeAppSettings(settings.value);

    return _updateSettingsState(
        appState,
            (settingsState) =>
            settingsState.copyWith(
              settings: settings,
            ));
  }
}

class ChangeDefaultLog implements MyAction {
  final Log log;

  ChangeDefaultLog({this.log});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    Map<String, Log> logs = appState.logsState.logs;
    if (log != null && logs.containsKey(log.id)) {
      settings = settings.copyWith(defaultLogId: log.id);
    }

    Env.settingsFetcher.writeAppSettings(settings);

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsAddEditCategory implements MyAction {
  final MyCategory category;

  SettingsAddEditCategory({@required this.category});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<MyCategory> categories = List.from(settings.defaultCategories);

    if (category.id != null) {
      categories[categories.indexWhere((e) => e.id == category.id)] = category;
    } else {
      categories.add(category.copyWith(id: Uuid().v4()));
    }

    settings = settings.copyWith(defaultCategories: categories);
    Env.settingsFetcher.writeAppSettings(settings);

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsDeleteCategory implements MyAction {
  final MyCategory category;

  SettingsDeleteCategory({@required this.category});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<MyCategory> categories = List.from(settings.defaultCategories);

    if (category.id != NO_CATEGORY) {
      //remove as long as the it is not NO_CATEGORY
      categories = categories.where((element) => element.id != category.id).toList();
      settings = settings.copyWith(defaultCategories: categories);
      Env.settingsFetcher.writeAppSettings(settings);
    }

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsAddEditSubcategory implements MyAction {
  final MyCategory subcategory;

  SettingsAddEditSubcategory({@required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<MyCategory> subcategories = settings.defaultSubcategories;

    if (subcategory.id != null) {
      subcategories[subcategories.indexWhere((e) => e.id == subcategory.id)] = subcategory;
    } else {
      subcategories.add(subcategory.copyWith(id: Uuid().v4()));
    }

    settings = settings.copyWith(defaultSubcategories: subcategories);
    Env.settingsFetcher.writeAppSettings(settings);

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SettingsDeleteSubcategory implements MyAction {
  final MyCategory subcategory;

  SettingsDeleteSubcategory({@required this.subcategory});

  @override
  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    List<MyCategory> subcategories = settings.defaultSubcategories;

    if (_canDeleteSubcategory(subcategory: subcategory)) {
      subcategories = subcategories.where((element) => element.id != subcategory.id).toList();
      settings = settings.copyWith(defaultSubcategories: subcategories);
      Env.settingsFetcher.writeAppSettings(settings);
    }

    return _updateSettingsState(appState, (settingsState) => settingsState.copyWith(settings: Maybe.some(settings)));
  }
}

class SetExpandedSettingsCategories implements MyAction {
  AppState updateState(AppState appState) {
    List<bool> expandedCategories = [];
    appState.settingsState.settings.value.defaultCategories.forEach((element) {
      expandedCategories.add(false);
    });

    return _updateSettingsState(
        appState, (settingsState) => settingsState.copyWith(expandedCategories: expandedCategories));
  }
}

class ExpandCollapseSettingsCategory implements MyAction {
  final int index;

  ExpandCollapseSettingsCategory({@required this.index});

  AppState updateState(AppState appState) {
    List<bool> expandedCategories = List.from(appState.settingsState.expandedCategories);
    expandedCategories[index] = !expandedCategories[index];

    return _updateSettingsState(
        appState, (settingsState) => settingsState.copyWith(expandedCategories: expandedCategories));
  }
}

class ReorderCategoryFromSettingsScreen implements MyAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;

  ReorderCategoryFromSettingsScreen({@required this.oldCategoryIndex, @required this.newCategoryIndex});

  AppState updateState(AppState appState) {
    //reorder categories list
    Settings settings = appState.settingsState.settings.value;
    List<MyCategory> categories = List.from(settings.defaultCategories);
    MyCategory movedCategory = categories.removeAt(oldCategoryIndex);
    categories.insert(newCategoryIndex, movedCategory);

    //reorder expanded list
    List<bool> expandedCategories = List.from(appState.settingsState.expandedCategories);
    bool movedExpansion = expandedCategories.removeAt(oldCategoryIndex);
    expandedCategories.insert(newCategoryIndex, movedExpansion);

    return _updateSettingsState(
        appState,
            (settingsState) =>
            settingsState.copyWith(
                settings: Maybe.some(settings.copyWith(defaultCategories: categories)),
                expandedCategories: expandedCategories));
  }
}

class ReorderSubcategoryFromSettingsScreen implements MyAction {
  final int oldCategoryIndex;
  final int newCategoryIndex;
  final int oldSubcategoryIndex;
  final int newSubcategoryIndex;

  ReorderSubcategoryFromSettingsScreen({@required this.oldCategoryIndex,
    @required this.newCategoryIndex,
    @required this.oldSubcategoryIndex,
    @required this.newSubcategoryIndex});

  AppState updateState(AppState appState) {
    Settings settings = appState.settingsState.settings.value;
    String oldParentId = settings.defaultCategories[oldCategoryIndex].id;
    String newParentId = settings.defaultCategories[newCategoryIndex].id;
    List<MyCategory> subcategories = List.from(settings.defaultSubcategories);
    List<MyCategory> subsetOfSubcategories = List.from(settings.defaultSubcategories);
    subsetOfSubcategories
        .retainWhere((subcategory) => subcategory.parentCategoryId == oldParentId); //get initial subset
    MyCategory subcategory = subsetOfSubcategories[oldSubcategoryIndex];


    subcategories = _reorderSubcategoriesLogSetting(newSubcategoryIndex: newSubcategoryIndex,
        subcategory: subcategory,
        newParentId: newParentId,
        oldParentId: oldParentId,
        subsetOfSubcategories: subsetOfSubcategories,
        subcategories: subcategories);

    return _updateSettingsState(
        appState,
            (settingsState) =>
            settingsState.copyWith(settings: Maybe.some(settings.copyWith(defaultSubcategories: subcategories))));
  }


}