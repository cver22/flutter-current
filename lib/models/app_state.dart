
import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/models/login/login_reg_state.dart';

import 'package:meta/meta.dart';

@immutable
class AppState {
  final AuthState authState;
  final LoginRegState loginRegState;



  AppState({
    @required this.authState,
    @required this.loginRegState,
  });

  AppState copyWith({
    AuthState authState,
    LoginRegState loginState,
  }) {
    return AppState(
      authState: authState ?? this.authState,
      loginRegState: loginState ?? this.loginRegState,
    );
  }

  factory AppState.initial() {
    return AppState(
      authState: AuthState.initial(),
      loginRegState: LoginRegState.initial(),
    );
  }
}
