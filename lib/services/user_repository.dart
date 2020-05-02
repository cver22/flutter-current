import 'dart:async';
import 'package:expenses/models/user/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

//TODO implement error checking

abstract class UserRepository {
  Future<FirebaseUser> signInWIthGoogle();

  Future<void> signInWithCredentials(String email, String password);

  Future<void> signUp({String email, String password});

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<String> getUserEmail();

  Future<String> getUserId();

  Future<String> getUserName();

  Future<String> getUserPhoto();

  Future<User> getUser();
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseUserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<FirebaseUser> signInWIthGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser();
  }

  @override
  Future<void> signInWithCredentials(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<bool> isSignedIn() async {
    final currentUser = await _firebaseAuth.currentUser();
    return currentUser != null;
  }

  @override
  Future<String> getUserEmail() async {
    return (await _firebaseAuth.currentUser()).email;
  }

  @override
  Future<String> getUserId() async {
    return (await _firebaseAuth.currentUser()).uid;
  }

  @override
  Future<String> getUserName() async {
    return (await _firebaseAuth.currentUser()).displayName;
  }

  @override
  Future<String> getUserPhoto() async {
    return (await _firebaseAuth.currentUser()).photoUrl;
  }

  @override
  Future<User> getUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    return User(
        id: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoUrl);
  }
}
