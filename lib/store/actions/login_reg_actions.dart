import '../../app/models/app_state.dart';
import '../../login_register/login_register_model/login_or_register.dart';
import '../../login_register/login_register_model/login_reg_state.dart';
import '../../utils/validators.dart';
import 'app_actions.dart';

AppState _updateLoginRegState(
  AppState appState,
  LoginRegState update(LoginRegState loginRegState),
) {
  return appState.copyWith(loginRegState: update(appState.loginRegState));
}

class LoginRegFailure implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(
        appState, (loginRegState) => loginRegState.failure());
  }
}

class LoginRegSubmitting implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(
        appState, (loginRegState) => loginRegState.submitting());
  }
}

class LoginRegSuccess implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(
        appState, (loginRegState) => loginRegState.success());
  }
}

class LoginOrCreateUser implements AppAction {
  //switches from between login or create new user
  @override
  AppState updateState(AppState appState) {
    LoginOrRegister loginOrRegister = appState.loginRegState.loginOrRegister;
    loginOrRegister = loginOrRegister == LoginOrRegister.login
        ? LoginOrRegister.register
        : LoginOrRegister.login;

    return _updateLoginRegState(
        appState,
        (loginRegState) =>
            loginRegState.copyWith(loginOrRegister: loginOrRegister));
  }
}

class LoginRegisterPasswordValidation implements AppAction {
  final String password;

  LoginRegisterPasswordValidation(this.password);

  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(
        appState,
        (loginRegState) => loginRegState.updateCredentials(
            isPasswordValid: Validators.isValidPassword(password)));
  }
}

class LoginRegisterEmailValidation implements AppAction {
  final String email;

  LoginRegisterEmailValidation(this.email);

  @override
  AppState updateState(AppState appState) {
    return _updateLoginRegState(
        appState,
        (loginRegState) => loginRegState.updateCredentials(
            isEmailValid: Validators.isValidEmail(email)));
  }
}
