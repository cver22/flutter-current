import 'package:equatable/equatable.dart';
import 'package:expenses/login_register/login_register_model/login__reg_status.dart';
import 'package:meta/meta.dart';

@immutable
class AccountState extends Equatable {
  final LoginStatus loginStatus;
  final bool isUserSignedInWithEmail;
  final bool showPasswordForm;
  final bool isSubmitting;
  final bool isOldPasswordValid;
  final bool isNewPasswordValid;
  final bool newPasswordsMatch;

  AccountState(
      {this.loginStatus,
        this.isUserSignedInWithEmail,
        this.showPasswordForm,
      this.isSubmitting,
      this.isOldPasswordValid,
      this.isNewPasswordValid,
      this.newPasswordsMatch});


  factory AccountState.initial() {
    return AccountState(
      loginStatus: LoginStatus.initial,
      isUserSignedInWithEmail: false,
      showPasswordForm: false,
      isSubmitting: false,
      isOldPasswordValid: true,
      isNewPasswordValid: true,
      newPasswordsMatch: true,
    );
  }

  AccountState submitting() {
    return copyWith(
      loginStatus: LoginStatus.submitting,
      isUserSignedInWithEmail: isUserSignedInWithEmail,
      showPasswordForm: false,
      isSubmitting: true,
      isOldPasswordValid: isOldPasswordValid,
      isNewPasswordValid: isNewPasswordValid,
      newPasswordsMatch: newPasswordsMatch,
    );
  }

  AccountState failure() {
    return copyWith(
      loginStatus: LoginStatus.failure,
      isUserSignedInWithEmail: isUserSignedInWithEmail,
      showPasswordForm: true,
      isSubmitting: false,
      isOldPasswordValid: isOldPasswordValid,
      isNewPasswordValid: isNewPasswordValid,
      newPasswordsMatch: newPasswordsMatch,
    );
  }

  AccountState success() {
    return copyWith(
      loginStatus: LoginStatus.success,
      isUserSignedInWithEmail: isUserSignedInWithEmail,
      showPasswordForm: false,
      isSubmitting: false,
      isOldPasswordValid: isOldPasswordValid,
      isNewPasswordValid: isNewPasswordValid,
      newPasswordsMatch: newPasswordsMatch,
    );
  }

  @override
  List<Object> get props => [loginStatus, showPasswordForm, isSubmitting, isOldPasswordValid, isNewPasswordValid, newPasswordsMatch];

  @override
  bool get stringify => true;

  AccountState copyWith({
    LoginStatus loginStatus,
    bool isUserSignedInWithEmail,
    bool showPasswordForm,
    bool isSubmitting,
    bool isOldPasswordValid,
    bool isNewPasswordValid,
    bool newPasswordsMatch,
  }) {
    if ((loginStatus == null || identical(loginStatus, this.loginStatus)) &&
        (isUserSignedInWithEmail == null || identical(isUserSignedInWithEmail, this.isUserSignedInWithEmail)) &&
        (showPasswordForm == null || identical(showPasswordForm, this.showPasswordForm)) &&
        (isSubmitting == null || identical(isSubmitting, this.isSubmitting)) &&
        (isOldPasswordValid == null || identical(isOldPasswordValid, this.isOldPasswordValid)) &&
        (isNewPasswordValid == null || identical(isNewPasswordValid, this.isNewPasswordValid)) &&
        (newPasswordsMatch == null || identical(newPasswordsMatch, this.newPasswordsMatch))) {
      return this;
    }

    return new AccountState(
      loginStatus: loginStatus ?? this.loginStatus,
      isUserSignedInWithEmail: isUserSignedInWithEmail ?? this.isUserSignedInWithEmail,
      showPasswordForm: showPasswordForm ?? this.showPasswordForm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isOldPasswordValid: isOldPasswordValid ?? this.isOldPasswordValid,
      isNewPasswordValid: isNewPasswordValid ?? this.isNewPasswordValid,
      newPasswordsMatch: newPasswordsMatch ?? this.newPasswordsMatch,
    );
  }


}