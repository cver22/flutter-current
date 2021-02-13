part of 'my_actions.dart';

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
