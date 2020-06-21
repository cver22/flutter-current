import 'package:expenses/models/auth/auth_status.dart';
import 'package:expenses/models/login/login_reg_state.dart';
import 'file:///D:/version-control/flutter/expenses/lib/models/user.dart';
import 'package:expenses/services/user_repository.dart';
import 'package:expenses/store/actions/actions.dart';
import 'package:expenses/store/app_store.dart';
import 'package:expenses/utils/maybe.dart';
import 'package:meta/meta.dart';

class UserFetcher {
  final AppStore _store;
  final FirebaseUserRepository _userRepository;

  UserFetcher({
    @required AppStore store,
    @required FirebaseUserRepository userRepository,
  })  : _store = store,
        _userRepository = userRepository;

  FirebaseUserRepository get repo => _userRepository;

  Future<void> startApp() async {
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final Maybe<User> user = Maybe.some(await _userRepository.getUser());
      _store.dispatch(UpdateAuthStatus(
        user: user,
        authStatus: AuthStatus.authenticated,
      ));
      print('User authenticated: $user');
    } else {
      _store.dispatch(UpdateAuthStatus(
        authStatus: AuthStatus.unauthenticated,
      ));
      print('User is not authenticated');
    }
  }

  //TODO do I need to map alreadyLoggedIn ?

  Future<void> signOut() async {
    _store.dispatch(SignOutState());
    await _userRepository.signOut();
  }

  Future<void> signInWithGoogle(LoginRegState loginRegState) async {
    _store.dispatch(UpdateLoginRegState(loginRegState: loginRegState.submitting()));
    try {
      await _userRepository.signInWithGoogle();
      User user = await _userRepository.getUser();
      print('google login: ${user.toString()}');
      _store.dispatch(UpdateLoginRegState(loginRegState: loginRegState.success()));
      print('got to here');
    } catch (e) {
      print(e.toString());
      _store.dispatch(UpdateLoginRegState(loginRegState: loginRegState.failure()));
    }
  }

  Future<void> signInWithCredentials(
      {String email, String password, LoginRegState loginRegState}) async {
    _store.dispatch(
        UpdateLoginRegState(loginRegState: loginRegState.submitting()));

    try {
      await _userRepository.signInWithCredentials(
          email: email, password: password);
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.success()));
    } catch (e) {
      print(e.toString());
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.failure()));
    }
  }

  Future<void> registerWithCredentials(
      {String email, String password, LoginRegState loginRegState}) async {
    _store.dispatch(
        UpdateLoginRegState(loginRegState: loginRegState.submitting()));
    try {
      await _userRepository.signUp(email: email, password: password);
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.success()));
    } catch (e) {
      print(e.toString());
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.failure()));
    }
  }

//TODO implement loading of logs and entries from firestore

}
