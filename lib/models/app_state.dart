import 'package:equatable/equatable.dart';
import 'package:expenses/models/auth/auth_state.dart';
import 'package:expenses/models/log/logs_state.dart';
import 'package:expenses/models/login_register/login_reg_state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState extends Equatable{
  final AuthState authState;
  final LoginRegState loginRegState;
  final LogsState logsState;
  //TODO Add single log state
  //TODO Add single Entry state
  //TODO add Entries state
  //TODO add categories state

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

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [authState, loginRegState, logsState];
}
