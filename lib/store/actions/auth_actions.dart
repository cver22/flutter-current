import 'package:meta/meta.dart';

import '../../app/models/app_state.dart';
import '../../auth_user/models/app_user.dart';
import '../../auth_user/models/auth_state.dart';
import '../../utils/maybe.dart';
import 'app_actions.dart';

AppState _updateAuthState(
  AppState appState,
  AuthState update(AuthState authState),
) {
  return appState.copyWith(authState: update(appState.authState));
}

class AuthFailure implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => AuthState.initial());
  }
}

class AuthSuccess implements AppAction {
  final AppUser user;

  AuthSuccess({@required this.user});

  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(
        appState,
        (authState) =>
            authState.copyWith(user: Maybe.some(user), isLoading: false));
  }
}

class AuthSignOut implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return AppState.initial();
  }
}

class AuthLoadingUser implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(
        appState, (authState) => authState.copyWith(isLoading: true));
  }
}

class AuthUpdateDisplayName implements AppAction {
  final String displayName;

  AuthUpdateDisplayName({@required this.displayName});

  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(
        appState,
        (authState) => authState.copyWith(
            user: Maybe.some(
                authState.user.value.copyWith(displayName: displayName))));
  }
}
