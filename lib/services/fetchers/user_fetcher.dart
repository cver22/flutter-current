import 'package:expenses/env.dart';
import 'package:expenses/models/login_register/login__reg_status.dart';
import 'package:expenses/models/login_register/login_or_register.dart';
import 'package:expenses/models/login_register/login_reg_state.dart';
import 'package:expenses/models/user.dart';
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

  _getCurrentUser(LoginRegState loginRegState) async {
    print('firing start app');
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final Maybe<User> user = Maybe.some(await _userRepository.getUser());
      _store.dispatch(UpdateAuthStatus(user: user, isLoading: false));
      _store.dispatch(
          UpdateLoginRegState(loginRegState: loginRegState.success()));
      print('User authenticated: $user');
    } else {
      _store.dispatch(UpdateAuthStatus(user: Maybe.none(), isLoading: false));
      print('User is not authenticated');
    }
  }

  _setLoadingAndSubmitting(LoginRegState loginRegState) {
    _store.dispatch(
        UpdateLoginRegState(loginRegState: loginRegState.submitting()));
    _store.dispatch(UpdateAuthStatus(isLoading: true));
  }

  _loginRegisterFail(LoginRegState loginRegState) {
    _store.dispatch(UpdateAuthStatus(user: Maybe.none(), isLoading: false));
    _store
        .dispatch(UpdateLoginRegState(loginRegState: loginRegState.failure()));
  }

  Future<void> startApp() async {
    _store.dispatch(UpdateAuthStatus(isLoading: true));
    _getCurrentUser(_store.state.loginRegState);
  }

  Future<void> signOut() async {
    _store.dispatch(SignOutState());
    await _userRepository.signOut();
  }

  Future<void> signInWithGoogle(LoginRegState loginRegState) async {
    _setLoadingAndSubmitting(loginRegState);
    try {
      await _userRepository.signInWithGoogle();
      _getCurrentUser(loginRegState);
    } catch (e) {
      print(e.toString());
      _loginRegisterFail(loginRegState);
    }
  }

  Future<void> signInOrRegisterWithCredentials(
      {String email, String password, LoginRegState loginRegState}) async {
    _setLoadingAndSubmitting(loginRegState);
    try {
      if (loginRegState.loginOrRegister == LoginOrRegister.login) {
        await _userRepository.signInWithCredentials(
            email: email, password: password);
      } else if (loginRegState.loginOrRegister == LoginOrRegister.register) {
        await _userRepository.signUp(email: email, password: password);
      }

      _getCurrentUser(loginRegState);
    } catch (e) {
      print(e.toString());
      _loginRegisterFail(loginRegState);
    }
  }
}
