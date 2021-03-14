import 'package:expenses/app/models/app_state.dart';
import 'package:expenses/auth_user/models/auth_state.dart';
import 'package:expenses/auth_user/models/app_user.dart';
import 'package:expenses/store/actions/app_actions.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

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
    return _updateAuthState(appState, (authState) => authState.copyWith(user: Maybe.some(user), isLoading: false));
  }
}

class SignOutState implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return AppState.initial();
  }
}

class LoadingUser implements AppAction {
  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState, (authState) => authState.copyWith(isLoading: true));
  }
}

class UpdateDisplayName implements AppAction {
  final String displayName;

  UpdateDisplayName({@required this.displayName});

  @override
  AppState updateState(AppState appState) {
    return _updateAuthState(appState,
        (authState) => authState.copyWith(user: Maybe.some(authState.user.value.copyWith(displayName: displayName))));
  }
}
