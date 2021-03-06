import '../login_register/login_register_model/login_or_register.dart';
import '../login_register/login_register_model/login_reg_state.dart';
import '../store/actions/account_actions.dart';
import '../store/actions/auth_actions.dart';
import '../store/actions/login_reg_actions.dart';
import '../store/app_store.dart';
import 'models/app_user.dart';
import 'user_repository.dart';

class UserFetcher {
  final AppStore _store;
  final FirebaseUserRepository _userRepository;

  UserFetcher({
    required AppStore store,
    required FirebaseUserRepository userRepository,
  })  : _store = store,
        _userRepository = userRepository;

  _getCurrentUser(LoginRegState? loginRegState) async {
    final isSignedIn = await _userRepository.isSignedIn();
    if (isSignedIn) {
      final AppUser user = await _userRepository.getUser();
      _store.dispatch(AuthSuccess(user: user));
      _store.dispatch(LoginRegSuccess());
      print('User authenticated');
    } else {
      _store.dispatch(AuthFailure());
      print('User is not authenticated');
    }
  }

  _setLoadingAndSubmitting(LoginRegState? loginRegState) {
    _store.dispatch(LoginRegSubmitting());
    _store.dispatch(AuthLoadingUser());
  }

  _loginRegisterFail(LoginRegState? loginRegState) {
    _store.dispatch(AuthFailure());
    _store.dispatch(LoginRegFailure());
  }

  Future<void> startApp() async {
    _store.dispatch(AuthLoadingUser());
    _getCurrentUser(_store.state.loginRegState);
  }

  Future<void> signOut() async {
    _store.dispatch(AuthSignOut());
    await _userRepository.signOut();
  }

  Future<void> signInWithGoogle(LoginRegState? loginRegState) async {
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
      {required String email, required String password, required LoginRegState loginRegState}) async {
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

  Future<void> updateDisplayName({required String displayName}) async {
    AppUser user =
        await _userRepository.updateUserProfile(displayName: displayName);
    _store.dispatch(AuthSuccess(user: user));
  }

  //used for AccountScreen password change form
  Future<void> isUserSignedInWithEmail() async {
    bool signedInWithEmail = await _userRepository.isUserSignedInWithEmail();
    _store.dispatch(
        IsUserSignedInWithEmail(signedInWithEmail: signedInWithEmail));
  }

  //only available if user has signed in with email
  Future<void> updatePassword(
      {required String currentPassword, required String newPassword}) async {
    _store.dispatch(AccountUpdateSubmitting());
    bool success = await _userRepository.updatePassword(
        currentPassword: currentPassword, newPassword: newPassword);
    if (success) {
      _store.dispatch(AccountUpdateSuccess());
    } else {
      _store.dispatch(AccountUpdateFailure());
    }
  }
}
