part of 'actions.dart';

class UpdateLoginRegState implements Action {
  final LoginRegState loginRegState;

  UpdateLoginRegState({this.loginRegState});

  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(loginState: loginRegState);
  }
}

class PasswordValidation implements Action {
  final String password;

  PasswordValidation(this.password);

  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(
        loginState: appState.loginRegState.updateCredentials(
            isPasswordValid: Validators.isValidPassword(password)));
  }
}

class EmailValidation implements Action {
  final String email;

  EmailValidation(this.email);

  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(
        loginState: appState.loginRegState.updateCredentials(
            isPasswordValid: Validators.isValidEmail(email)));
  }
}
