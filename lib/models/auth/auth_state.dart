import 'package:expenses/models/auth/auth_status.dart';
import 'file:///D:/version-control/flutter/expenses/lib/models/user.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';


@immutable
class AuthState {
  final Maybe<User> user;
  final AuthStatus authStatus;

  AuthState({this.user, this.authStatus});

  AuthState copyWith({
    Maybe<User> user,
    AuthStatus authStatus,
  }) {
    return AuthState(
      user: user ?? this.user,
      authStatus: authStatus ?? this.authStatus,
    );
  }

  factory AuthState.initial() {
    return AuthState(
      user: Maybe.none(),
      authStatus: AuthStatus.unauthenticated,
    );
  }
}
