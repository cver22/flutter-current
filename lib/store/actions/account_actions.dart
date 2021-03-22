import '../../account/account_model/account_state.dart';
import '../../app/models/app_state.dart';
import '../../login_register/login_register_model/login__reg_status.dart';
import '../../utils/validators.dart';
import 'app_actions.dart';

AppState _updateAccountState(
  AppState appState,
  AccountState update(AccountState accountState),
) {
  return appState.copyWith(accountState: update(appState.accountState));
}

class AccountUpdateFailure implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState, (accountState) => accountState.failure());
  }
}

class AccountUpdateSubmitting implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState, (accountState) => accountState.submitting());
  }
}

class AccountUpdateSuccess implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState, (accountState) => accountState.success());
  }
}

class ShowHidePasswordForm implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState,
        (accountState) => accountState.copyWith(
            showPasswordForm: !appState.accountState.showPasswordForm));
  }
}

class AccountResetState implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState, (accountState) => accountState.resetState());
  }
}

class AccountValidateOldPassword implements AppAction {
  final String password;

  /*final String newPassword;
  final String verifyPassword*/

  AccountValidateOldPassword({this.password});

  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState,
        (accountState) => accountState.copyWith(
            isOldPasswordValid: Validators.isValidPassword(password),
            loginStatus: LoginStatus.updated));
  }
}

class AccountValidateNewPassword implements AppAction {
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
            isNewPasswordValid: Validators.isValidPassword(newPassword),
            newPasswordsMatch: passwordsMatch,
            loginStatus: LoginStatus.updated));
  }
}

class IsUserSignedInWithEmail implements AppAction {
  final bool signedInWithEmail;

  IsUserSignedInWithEmail({this.signedInWithEmail});

  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState,
        (accountState) =>
            accountState.copyWith(isUserSignedInWithEmail: signedInWithEmail));
  }
}
