import '../../account/account_model/account_state.dart';
import '../../app/models/app_state.dart';
import '../../login_register/login_register_model/login__reg_status.dart';
import '../../utils/validators.dart';
import 'app_actions.dart';

AppState Function(AppState) _updateAccountState(AccountState update(accountState)) {
  return (state) => state.copyWith(accountState: update(state.accountState));
}

class AccountUpdateFailure implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateAccountState((accountState) => accountState.failure()),
      ],
    );
  }
}

class AccountUpdateSubmitting implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateAccountState((accountState) => accountState.submitting()),
      ],
    );
  }
}

class AccountUpdateSuccess implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateAccountState((accountState) => accountState.success()),
      ],
    );
  }
}

class ShowHidePasswordForm implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateAccountState(
            (accountState) => accountState.copyWith(showPasswordForm: !appState.accountState.showPasswordForm)),
      ],
    );
  }
}

class AccountResetState implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateAccountState((accountState) => accountState.resetState()),
      ],
    );
  }
}

class AccountValidateOldPassword implements AppAction {
  final String password;

  AccountValidateOldPassword({this.password});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateAccountState((accountState) => accountState.copyWith(
            isOldPasswordValid: Validators.isValidPassword(password), loginStatus: LoginStatus.updated)),
      ],
    );
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

    return updateSubstates(
      appState,
      [
        _updateAccountState((accountState) => accountState.copyWith(
            isNewPasswordValid: Validators.isValidPassword(newPassword),
            newPasswordsMatch: passwordsMatch,
            loginStatus: LoginStatus.updated)),
      ],
    );
  }
}

class IsUserSignedInWithEmail implements AppAction {
  final bool signedInWithEmail;

  IsUserSignedInWithEmail({this.signedInWithEmail});

  @override
  AppState updateState(AppState appState) {
    return updateSubstates(
      appState,
      [
        _updateAccountState((accountState) => accountState.copyWith(isUserSignedInWithEmail: signedInWithEmail)),
      ],
    );
  }
}
