import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/models/log/logs_state.dart';
import 'package:expenses/models/login_register/login_reg_state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  final AuthState authState;
  final LoginRegState loginRegState;
  final LogsState logsState;

  AppState({
    @required this.authState,
    @required this.loginRegState,
    @required this.logsState,
  });

  AppState copyWith({
    AuthState authState,
    LoginRegState loginState,
    LogsState logsState,
  }) {
    return AppState(
        authState: authState ?? this.authState,
        loginRegState: loginState ?? this.loginRegState,
        logsState: logsState ?? this.logsState);
  }

  factory AppState.initial() {
    return AppState(
      authState: AuthState.initial(),
      loginRegState: LoginRegState.initial(),
      logsState: LogsState.initial(),
    );
  }
}
