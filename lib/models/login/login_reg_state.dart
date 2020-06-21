import 'package:expenses/models/login/login_or_register.dart';
import 'package:expenses/models/login/login__reg_status.dart';
import 'package:meta/meta.dart';

// empty is the initial state of the LoginForm.
// loading is the state of the LoginForm when we are validating credentials
// failure is the state of the LoginForm when a login attempt has failed.
// success is the state of the LoginForm when a login attempt has succeeded.

@immutable
class LoginRegState {
  final LoginStatus loginStatus;
  final LoginOrRegister loginOrRegister;
  final bool isEmailValid;
  final bool isPasswordValid;

  bool get isFormValid => isEmailValid && isPasswordValid;

  LoginRegState({
    @required this.loginStatus,
    @required this.loginOrRegister,
    @required this.isEmailValid,
    @required this.isPasswordValid,
  });

  factory LoginRegState.initial() {
    return LoginRegState(
      loginStatus: LoginStatus.initial,
      loginOrRegister:  LoginOrRegister.login,
      isEmailValid: true,
      isPasswordValid: true,
    );
  }

  LoginRegState submitting() {
    return copyWith(
      loginStatus: LoginStatus.submitting,
      loginOrRegister: this.loginOrRegister,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,

    );
  }

  LoginRegState failure() {
    return copyWith(
      loginStatus: LoginStatus.failure,
      loginOrRegister: this.loginOrRegister,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,

    );
  }

  LoginRegState success() {
    return copyWith(
      loginStatus: LoginStatus.success,
      loginOrRegister: this.loginOrRegister,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,

    );
  }

  LoginRegState updateCredentials({
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return copyWith(
      loginStatus: LoginStatus.updated,
      loginOrRegister: this.loginOrRegister,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,

    );
  }

  LoginRegState copyWith({
    LoginStatus loginStatus,
    LoginOrRegister loginOrRegister,
    bool isEmailValid,
    bool isPasswordValid,
  }) {
    return LoginRegState(
      loginStatus: loginStatus ?? this.loginStatus,
      loginOrRegister: loginOrRegister ?? this.loginOrRegister,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
    );
  }

  @override
  String toString() {
    return '''{LoginState {
    loginStatus: $loginStatus,
    isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      }''';
  }
}