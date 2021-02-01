import 'package:equatable/equatable.dart';
import 'package:expenses/login_register/login_register_model/login__reg_status.dart';
import 'package:expenses/login_register/login_register_model/login_or_register.dart';
import 'package:meta/meta.dart';

// empty is the initial state of the LoginForm.
// loading is the state of the LoginForm when we are validating credentials
// failure is the state of the LoginForm when a login attempt has failed.
// success is the state of the LoginForm when a login attempt has succeeded.

@immutable
class LoginRegState extends Equatable{
  final LoginStatus loginStatus;
  final LoginOrRegister loginOrRegister;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isSubmitting;

  bool get isFormValid => isEmailValid && isPasswordValid;

  LoginRegState({
    @required this.loginStatus,
    @required this.loginOrRegister,
    @required this.isEmailValid,
    @required this.isPasswordValid,
    @required this.isSubmitting,
  });

  factory LoginRegState.initial() {
    return LoginRegState(
      loginStatus: LoginStatus.initial,
      loginOrRegister: LoginOrRegister.login,
      isEmailValid: true,
      isPasswordValid: true,
      isSubmitting: false,
    );
  }

  LoginRegState submitting() {
    return copyWith(
      loginOrRegister: this.loginOrRegister,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: true,
    );
  }

  LoginRegState failure() {
    return copyWith(
      loginStatus: LoginStatus.failure,
      loginOrRegister: this.loginOrRegister,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
    );
  }

  LoginRegState success() {
    return copyWith(
      loginStatus: LoginStatus.success,
      loginOrRegister: this.loginOrRegister,
      isEmailValid: isEmailValid,
      isPasswordValid: isPasswordValid,
      isSubmitting: false,
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
      isSubmitting: false,
    );
  }

  LoginRegState copyWith({
    LoginStatus loginStatus,
    LoginOrRegister loginOrRegister,
    bool isEmailValid,
    bool isPasswordValid,
    bool isSubmitting,
  }) {
    return LoginRegState(
      loginStatus: loginStatus ?? this.loginStatus,
      loginOrRegister: loginOrRegister ?? this.loginOrRegister,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  String toString() {
    return '''{LoginState {
    loginStatus: $loginStatus,
    isEmailValid: $isEmailValid,
      isPasswordValid: $isPasswordValid,
      isSubmitting: $isSubmitting,
      }''';
  }

  @override
  List<Object> get props => [loginStatus, loginOrRegister, isEmailValid, isPasswordValid, isSubmitting];

  @override
  bool get stringify => true;
}
