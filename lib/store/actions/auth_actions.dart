part of 'actions.dart';

class UpdateAuthStatus implements Action {
  final AuthStatus authStatus;
  final Maybe<User> user;

  UpdateAuthStatus({this.authStatus, this.user});

  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(
        authState:
            appState.authState.copyWith(authStatus: authStatus, user: user));
  }
}

class SignOutState implements Action {
  @override
  AppState updateState(AppState appState) {

    return appState.copyWith(authState: AuthState.initial(), loginState: LoginRegState.initial());

  }

}
