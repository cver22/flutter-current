part of 'authentication_bloc.dart';

// an AppStarted event to notify the bloc that it needs to check if the user is currently authenticated or not.
// a LoggedIn event to notify the bloc that the user has successfully logged in.
// a LoggedOut event to notify the bloc that the user has successfully logged out.

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}
