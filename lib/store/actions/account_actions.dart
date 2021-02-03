part of 'actions.dart';

AppState _updateAccountState(
  AppState appState,
  AccountState update(AccountState accountState),
) {
  return appState.copyWith(accountState: update(appState.accountState));
}

class AccountUpdateFailure implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.failure());
  }
}

class AccountUpdateSubmitting implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.submitting());
  }
}

class AccountUpdateSuccess implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.success());
  }
}

class ShowHidePasswordForm implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.copyWith(showPasswordForm: !appState.accountState.showPasswordForm));
  }
}

class AccountResetState implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(appState, (accountState) => accountState.resetState());
  }
}

class AccountValidateOldPassword implements Action {
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

class AccountValidateNewPassword implements Action {
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

class IsUserSignedInWithEmail implements Action {
  final bool signedInWithEmail;

  IsUserSignedInWithEmail({this.signedInWithEmail});

  @override
  AppState updateState(AppState appState) {
    return _updateAccountState(
        appState, (accountState) => accountState.copyWith(isUserSignedInWithEmail: signedInWithEmail));
  }
}
