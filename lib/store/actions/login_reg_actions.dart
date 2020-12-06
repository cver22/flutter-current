part of 'actions.dart';

AppState _updateLoginRegState(
  AppState appState,
  LoginRegState update(LoginRegState loginRegState),
) {
  return appState.copyWith(loginState: update(appState.loginRegState));
}

class LoginRegFailure implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState, (loginRegState) => loginRegState.failure());
  }
}

class LoginRegSubmitting implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState, (loginRegState) => loginRegState.submitting());
  }
}

class LoginRegSuccess implements Action {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState, (loginRegState) => loginRegState.success());
  }
}

class LoginOrCreateUser implements Action {
  //switches from between login or create new user
  @override
  AppState updateState(AppState appState) {
    LoginOrRegister loginOrRegister = appState.loginRegState.loginOrRegister;
    loginOrRegister = loginOrRegister == LoginOrRegister.login ? LoginOrRegister.register : LoginOrRegister.login;

    return _updateLoginRegState(appState, (loginRegState) => loginRegState.copyWith(loginOrRegister: loginOrRegister));
  }
}

class PasswordValidation implements Action {
  final String password;

  PasswordValidation(this.password);

  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(appState,
        (loginRegState) => loginRegState.updateCredentials(isPasswordValid: Validators.isValidPassword(password)));
  }
}

class EmailValidation implements Action {
  final String email;

  EmailValidation(this.email);

  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(
        appState, (loginRegState) => loginRegState.updateCredentials(isEmailValid: Validators.isValidEmail(email)));
  }
}
