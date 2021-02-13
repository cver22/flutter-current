part of 'my_actions.dart';

AppState _updateAuthState(
  AppState appState,
  AuthState update(AuthState authState),
) {
  return appState.copyWith(authState: update(appState.authState));
}

class AuthFailure implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => AuthState.initial());
  }
}

class AuthSuccess implements MyAction {
  final User user;

  AuthSuccess({@required this.user});

  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => authState.copyWith(user: Maybe.some(user), isLoading: false));
  }
}

class SignOutState implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return AppState.initial();
  }
}

class LoadingUser implements MyAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => authState.copyWith(isLoading: true));
  }
}

class UpdateDisplayName implements MyAction {
  final String displayName;

  UpdateDisplayName({@required this.displayName});

  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => authState.copyWith(user: Maybe.some(authState.user.value.copyWith(displayName: displayName))));
  }
}