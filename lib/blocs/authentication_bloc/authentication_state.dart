part of 'authentication_bloc.dart';

// States
// uninitialized - waiting to see if the user is authenticated or not on app start.
// authenticated - successfully authenticated
// unauthenticated - not authenticated

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];

  //used for printing to console
  @override
  String toString() => 'Authenticated {user: $user}';
}

class Unauthenticated extends AuthenticationState {}
