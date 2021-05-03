import 'package:equatable/equatable.dart';
import '../../login_register/login_register_model/login__reg_status.dart';
import 'package:meta/meta.dart';

//AccountState is used for tracking password changes by the user
@immutable
class AccountState extends Equatable {
  final LoginStatus loginStatus;
  final bool isUserSignedInWithEmail;
  final bool showPasswordForm;
  final bool isOldPasswordValid;
  final bool isNewPasswordValid;
  final bool newPasswordsMatch;

  AccountState(
      {required this.loginStatus,
      required this.isUserSignedInWithEmail,
      required this.showPasswordForm,
      required this.isOldPasswordValid,
      required this.isNewPasswordValid,
      required this.newPasswordsMatch});

  factory AccountState.initial() {
    return AccountState(
      loginStatus: LoginStatus.initial,
      isUserSignedInWithEmail: false,
      showPasswordForm: false,
      isOldPasswordValid: true,
      isNewPasswordValid: true,
      newPasswordsMatch: false,
    );
  }

  AccountState resetState() {
    return copyWith(
      loginStatus: LoginStatus.initial,
      isUserSignedInWithEmail: isUserSignedInWithEmail,
      showPasswordForm: false,
      isOldPasswordValid: true,
      isNewPasswordValid: true,
      newPasswordsMatch: false,
    );
  }

  AccountState submitting() {
    return copyWith(
      loginStatus: LoginStatus.submitting,
      isUserSignedInWithEmail: isUserSignedInWithEmail,
      showPasswordForm: false,
      isOldPasswordValid: true,
      isNewPasswordValid: true,
      newPasswordsMatch: false,
    );
  }

  AccountState failure() {
    return copyWith(
      loginStatus: LoginStatus.failure,
      isUserSignedInWithEmail: isUserSignedInWithEmail,
      showPasswordForm: true,
      isOldPasswordValid: true,
      isNewPasswordValid: true,
      newPasswordsMatch: false,
    );
  }

  AccountState success() {
    return copyWith(
      loginStatus: LoginStatus.success,
      isUserSignedInWithEmail: isUserSignedInWithEmail,
      showPasswordForm: false,
      isOldPasswordValid: isOldPasswordValid,
      isNewPasswordValid: isNewPasswordValid,
      newPasswordsMatch: false,
    );
  }

  @override
  List<Object> get props => [
        loginStatus,
        showPasswordForm,
        isOldPasswordValid,
        isNewPasswordValid,
        newPasswordsMatch
      ];

  @override
  bool get stringify => true;

  AccountState copyWith({
    LoginStatus? loginStatus,
    bool? isUserSignedInWithEmail,
    bool? showPasswordForm,
    bool? isOldPasswordValid,
    bool? isNewPasswordValid,
    bool? newPasswordsMatch,
  }) {
    if ((loginStatus == null || identical(loginStatus, this.loginStatus)) &&
        (isUserSignedInWithEmail == null ||
            identical(isUserSignedInWithEmail, this.isUserSignedInWithEmail)) &&
        (showPasswordForm == null ||
            identical(showPasswordForm, this.showPasswordForm)) &&
        (isOldPasswordValid == null ||
            identical(isOldPasswordValid, this.isOldPasswordValid)) &&
        (isNewPasswordValid == null ||
            identical(isNewPasswordValid, this.isNewPasswordValid)) &&
        (newPasswordsMatch == null ||
            identical(newPasswordsMatch, this.newPasswordsMatch))) {
      return this;
    }

    return new AccountState(
      loginStatus: loginStatus ?? this.loginStatus,
      isUserSignedInWithEmail:
          isUserSignedInWithEmail ?? this.isUserSignedInWithEmail,
      showPasswordForm: showPasswordForm ?? this.showPasswordForm,
      isOldPasswordValid: isOldPasswordValid ?? this.isOldPasswordValid,
      isNewPasswordValid: isNewPasswordValid ?? this.isNewPasswordValid,
      newPasswordsMatch: newPasswordsMatch ?? this.newPasswordsMatch,
    );
  }
}
