import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as authLib;
import 'package:ufr/models/user.dart';
import 'package:ufr/services/database.dart';

class AuthService {
  authLib.FirebaseAuth _auth;

  AuthService() {
    try {
      _auth = authLib.FirebaseAuth.instance;
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<User> _userFromFirebaseUser(authLib.User user) async {
    try {
      if (user == null) return null;

      DocumentSnapshot userDoc =
          await DatabaseService().getUserProfile(user.uid);

      if (userDoc.exists)
        return User(
            userId: user.uid,
            utilityId: userDoc.data()['utility_id'],            
            utilityName: await DatabaseService()
          .getUtilityByUtilityId(userDoc.data()['utility_id'])
          .then((value) {
        return value.docs.first.data()['foreign_name'];
      }),
            personName: userDoc.data()['person_name'],
            email: user.email);
      else
        return null;
    } on Exception catch (e) {
      throw e;
    }
  }

  // auth change user stream
  Stream<User> get user {
    try {
      Stream<authLib.User> myStream = _auth.authStateChanges();
      return myStream.asyncMap((event) => _userFromFirebaseUser(event));
    } on Exception catch (e) {
      throw e;
    }
  }

  // sign in anon
  Future signInAnon() async {
    try {
      authLib.UserCredential result = await _auth.signInAnonymously();
      authLib.User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      throw e;
    }
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      authLib.UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      authLib.User user = result.user;
      return user;
    } catch (e) {
      throw e;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
      String email, String password, int utilityId, String personName) async {
    try {
      authLib.UserCredential result = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // create a new document for the user with the uid
      DatabaseService()
          .updateUserProfile(result.user.uid, utilityId, personName);

      return _userFromFirebaseUser(result.user);
    } on Exception catch (e) {
      throw e;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      throw e;
    }
  }
}
