import 'dart:async';
import 'file:///D:/version-control/flutter/expenses/lib/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

//TODO implement error checking

abstract class UserRepository {
  Future<FirebaseUser> signInWithGoogle();

  Future<void> signInWithCredentials({String email, String password});

  Future<void> signUp({String email, String password});

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<User> getUser();
}

class FirebaseUserRepository implements UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseUserRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<FirebaseUser> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser();
  }

  @override
  Future<void> signInWithCredentials({String email, String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  @override
  Future<void> signUp({String email, String password}) async {

    var auth = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    auth.toString();

    return auth;
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
  Future<User> getUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    return User(
        id: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoUrl);
  }
}
