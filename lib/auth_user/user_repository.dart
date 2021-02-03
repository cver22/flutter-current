import 'dart:async';
import 'package:expenses/auth_user/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

//TODO implement error checking

abstract class UserRepository {
  Future<FirebaseUser> signInWithGoogle();

  Future<void> signInWithCredentials({String email, String password});

  Future<void> signUp({String email, String password});

  Future<void> signOut();

  Future<bool> isSignedIn();

  Future<User> getUser();

  Future<User> updateUserProfile({@required String displayName});

  Future<bool> updatePassword({@required String currentPassword, @required String newPassword});

  Future<bool> isUserSignedInWithEmail();
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
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential =
        GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    await _firebaseAuth.signInWithCredential(credential);
    return _firebaseAuth.currentUser();
  }

  @override
  Future<void> signInWithCredentials({String email, String password}) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signUp({String email, String password}) async {
    var auth = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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

    return User(id: user.uid, displayName: user.displayName, email: user.email, photoUrl: user.photoUrl);
  }

  @override
  Future<User> updateUserProfile({@required String displayName}) async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    UserUpdateInfo userUpdateInfo = UserUpdateInfo();
    userUpdateInfo.displayName = displayName;
    user.updateProfile(userUpdateInfo);
    await user.reload();
    user = await _firebaseAuth.currentUser();

    return User(id: user.uid, displayName: user.displayName, email: user.email, photoUrl: user.photoUrl);
  }

  @override
  Future<bool> updatePassword({@required String currentPassword, @required String newPassword}) async {
   // FirebaseUser user = await _firebaseAuth.currentUser();
    bool success = false;

   // AuthCredential authCredentials = EmailAuthProvider.getCredential(email: user.email, password: currentPassword);

    /*await user.reauthenticateWithCredential(authCredentials).then((_) async {
      await user.updatePassword(newPassword).then((_) {
        print("Successfully changed password");
        success = true;
      }).catchError((error) {
        print("Password can't be changed" + error.toString());

        //This might happen, when the wrong password is entered, the user isn't found, or if the user hasn't logged in recently.
      });
    }).catchError((error) {
      print("Password can't be changed" + error.toString());
    });*/

    await Future.delayed(Duration(milliseconds: 2000));

    return success;
  }

  @override
  Future<bool> isUserSignedInWithEmail() async {
    FirebaseUser user = await _firebaseAuth.currentUser();

    //returns true if user has signed into the app with their email
    return user.providerData[1].providerId == EmailAuthProvider.providerId;
  }
}
