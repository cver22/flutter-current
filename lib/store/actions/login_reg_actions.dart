part of 'actions.dart';

//TODO modify to utilize a private function similar to the others

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
