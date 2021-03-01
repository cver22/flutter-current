import 'package:equatable/equatable.dart';
import 'package:expenses/account/account_model/account_state.dart';
import 'package:expenses/auth_user/models/auth_state.dart';
import 'package:expenses/entries/entries_model/entries_state.dart';
import 'package:expenses/entry/entry_model/single_entry_state.dart';
import 'package:expenses/filter/filter_model/filter_state.dart';
import 'package:expenses/log/log_model/logs_state.dart';
import 'package:expenses/log/log_totals_model/log_totals_state.dart';
import 'package:expenses/login_register/login_register_model/login_reg_state.dart';
import 'package:expenses/settings/settings_model/settings_state.dart';
import 'package:expenses/tags/tag_model/tag_state.dart';

import 'package:meta/meta.dart';

@immutable
class AppState extends Equatable {
  final AuthState authState;
  final LoginRegState loginRegState;
  final LogsState logsState;
  final EntriesState entriesState;
  final SettingsState settingsState;
  final SingleEntryState singleEntryState;
  final TagState tagState;
  final LogTotalsState logTotalsState;
  final AccountState accountState;
  final FilterState filterState;

  AppState(
      {@required this.authState,
      @required this.loginRegState,
      @required this.logsState,
      @required this.entriesState,
      @required this.settingsState,
      @required this.singleEntryState,
      @required this.tagState,
      @required this.logTotalsState,
      @required this.accountState,
      @required this.filterState});

  factory AppState.initial() {
    return AppState(
      authState: AuthState.initial(),
      loginRegState: LoginRegState.initial(),
      logsState: LogsState.initial(),
      entriesState: EntriesState.initial(),
      settingsState: SettingsState.initial(),
      singleEntryState: SingleEntryState.initial(),
      tagState: TagState.initial(),
      logTotalsState: LogTotalsState.initial(),
      accountState: AccountState.initial(),
      filterState: FilterState.initial(),
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        authState,
        loginRegState,
        logsState,
        entriesState,
        settingsState,
        singleEntryState,
        tagState,
        logTotalsState,
        accountState
      ];

  AppState copyWith({
    AuthState authState,
    LoginRegState loginRegState,
    LogsState logsState,
    EntriesState entriesState,
    SettingsState settingsState,
    SingleEntryState singleEntryState,
    TagState tagState,
    LogTotalsState logTotalsState,
    AccountState accountState,
    FilterState filterState,
  }) {
    if ((authState == null || identical(authState, this.authState)) &&
        (loginRegState == null || identical(loginRegState, this.loginRegState)) &&
        (logsState == null || identical(logsState, this.logsState)) &&
        (entriesState == null || identical(entriesState, this.entriesState)) &&
        (settingsState == null || identical(settingsState, this.settingsState)) &&
        (singleEntryState == null || identical(singleEntryState, this.singleEntryState)) &&
        (tagState == null || identical(tagState, this.tagState)) &&
        (logTotalsState == null || identical(logTotalsState, this.logTotalsState)) &&
        (accountState == null || identical(accountState, this.accountState)) &&
        (filterState == null || identical(filterState, this.filterState))) {
      return this;
    }

    return new AppState(
      authState: authState ?? this.authState,
      loginRegState: loginRegState ?? this.loginRegState,
      logsState: logsState ?? this.logsState,
      entriesState: entriesState ?? this.entriesState,
      settingsState: settingsState ?? this.settingsState,
      singleEntryState: singleEntryState ?? this.singleEntryState,
      tagState: tagState ?? this.tagState,
      logTotalsState: logTotalsState ?? this.logTotalsState,
      accountState: accountState ?? this.accountState,
      filterState: filterState ?? this.filterState,
    );
  }
}
