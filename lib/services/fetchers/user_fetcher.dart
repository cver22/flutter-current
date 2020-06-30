import 'dart:io';

import 'package:expenses/models/login_register/login_reg_state.dart';
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

//  FirebaseUserRepository get repo => _userRepository;

  _startApp() async {
    print('firing start app');
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      _store.dispatch(UpdateAuthStatus(isLoading: true));
      final Maybe<User> user = Maybe.some(await _userRepository.getUser());
      _store.dispatch(UpdateAuthStatus(user: user, isLoading: false));
      print('User authenticated: $user');
    } else {
      _store.dispatch(UpdateAuthStatus(user: Maybe.none(), isLoading: false));
      print('User is not authenticated');
    }
  }

  //TODO do I need to map alreadyLoggedIn ?

  Future<void> signOut() async {
    _store.dispatch(SignOutState());
    await _userRepository.signOut();
  }

  Future<void> signInWithGoogle(LoginRegState loginRegState) async {
    _store.dispatch(
        UpdateLoginRegState(loginRegState: loginRegState.submitting()));
    try {
      await _userRepository.signInWithGoogle();
      _startApp();
      _store.dispatch(UpdateLoginRegState(loginRegState: loginRegState.success()));
    } catch (e) {
      print(e.toString());
      _store.dispatch(UpdateAuthStatus(user: Maybe.none(), isLoading: false));
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.failure()));
    }
  }

  Future<void> signInWithCredentials(
      {String email, String password, LoginRegState loginRegState}) async {
    _store.dispatch(
        UpdateLoginRegState(loginRegState: loginRegState.submitting()));

    try {
      await _userRepository.signInWithCredentials(
          email: email, password: password);
      _startApp();
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
      _startApp();
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.success()));
    } catch (e) {
      print(e.toString());
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.failure()));
    }
  }
}
