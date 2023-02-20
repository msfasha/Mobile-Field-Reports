import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as authlib;
import 'aws_data_service.dart';
import 'modules.dart';

import 'package:ufr/models/user_profile.dart';

class AuthenticationService {
  // auth change user stream
  static Stream<UserProfile?> get userStatusStream {
    try {
      Stream<authlib.User?> myStream =
          authlib.FirebaseAuth.instance.authStateChanges();
      return myStream
          .asyncMap((event) => extractUserProfileForFirebaseUser(event));
    } catch (e) {
      rethrow;
    }
  }

  // sign in with email and password
  static Future signInWithEmailAndPassword(
      String email, String password) async {
    OperationResult or = OperationResult();
    try {
      authlib.UserCredential result = await authlib.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      authlib.User? user = result.user;

      or.operationCode = OperationResultCodeEnum.success;
      or.content = user;
      return or;
    } catch (e) {
      String errMsg = e.toString();
      if (e is authlib.FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          errMsg = 'email address is invalid, enter a valid email';
        } else if (e.code == 'user-not-found') {
          errMsg = 'Invalid credentials..';
        } else if (e.code == 'wrong-password') {
          errMsg = 'Invalid credentials';
        } else {
          errMsg = e.toString();
        }
      } else {
        errMsg = e.toString();
      }

      or.operationCode = OperationResultCodeEnum.error;
      or.message = errMsg;
      return or;
    }
  }

  // register with email and password
  static Future registerWithEmailAndPassword(String email, String password,
      String agencyId, String personName, String phoneNumber) async {
    OperationResult or = OperationResult();
    try {
      // create a new document for the user with the uid
      await DataService.updateUserProfile(
          (await authlib.FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email, password: password))
              .user!
              .uid,
          agencyId,
          personName,
          phoneNumber,
          email);

      AuthenticationService.signOut();

      return or;
    } catch (e) {
      String errMsg = e.toString();
      if (e is authlib.FirebaseAuthException) {
        if (e.code == 'invalid-email') {
          errMsg = 'email address is invalid, enter a valid email';
        } else if (e.code == 'user-not-found') {
          errMsg = 'Invalid credentials..';
        } else if (e.code == 'wrong-password') {
          errMsg = 'Invalid credentials';
        } else if (e.code == 'weak-password') {
          errMsg = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errMsg = 'The account already exists for that email.';
        } else {
          errMsg = e.toString();
        }
      } else {
        errMsg = e.toString();
      }

      or.operationCode = OperationResultCodeEnum.error;
      or.message = errMsg;
      return or;
    }
  }

  // sign out
  static Future signOut() async {
    try {
      if (authlib.FirebaseAuth.instance.currentUser != null) {
        await authlib.FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      rethrow;
    }
  }
}

Future<UserProfile?> extractUserProfileForFirebaseUser(
    authlib.User? user) async {
  try {
    if (user == null) return null;

    DocumentSnapshot userProfileDoc =
        await DataService.getUserProfile(user.uid);

    if (!userProfileDoc.exists) return null;

    UserProfile userProfile = mapFirebaseUserToUserProfile(userProfileDoc);
    userProfile.agencyName =
        await DataService.getAgencyNameByAgencyId(userProfileDoc['agency_id']);

    return userProfile;
  } catch (e) {
    rethrow;
  }
}
