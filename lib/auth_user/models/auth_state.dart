import 'app_user.dart';
import '../../utils/maybe.dart';
import 'package:meta/meta.dart';

@immutable
class AuthState {
  final Maybe<AppUser> user;
  final bool isLoading;

  AuthState({
    required this.user,
    required this.isLoading,
  });

  AuthState copyWith({
    Maybe<AppUser>? user,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory AuthState.initial() {
    return AuthState(
      user: Maybe.none(),
      isLoading: false,
    );
  }
}
