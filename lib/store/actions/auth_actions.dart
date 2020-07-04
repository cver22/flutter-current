part of 'actions.dart';

class UpdateAuthStatus implements Action {
  final Maybe<User> user;
  final bool isLoading;

  UpdateAuthStatus({this.user, this.isLoading});

  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(
        authState: appState.authState.copyWith(user: user, isLoading: isLoading));
  }
}

class SignOutState implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(
        authState: AuthState.initial(), loginState: LoginRegState.initial(), logsState: LogsState.initial());
    //TODO reset all states to initial
  }
}

class LoadingUser implements Action {
  @override
  AppState updateState(AppState appState) {
    return appState.copyWith(authState: appState.authState.copyWith(isLoading: true));
  }
}
