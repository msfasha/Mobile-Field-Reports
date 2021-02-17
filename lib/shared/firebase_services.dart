import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as authLib;
import 'package:ufr/models/user_profile.dart';

import 'modules.dart';

UserProfile mapFirebaseUserToUserProfile(DocumentSnapshot doc) {
  return UserProfile(
      userId: doc.id,
      agencyId: doc.data()['agency_id'],
      personName: doc.data()['person_name'],
      phoneNumber: doc.data()['phone_number'],
      email: doc.data()['email'],
      userCategory: doc.data()['user_category'],
      creationDate: doc.data()['creation_date'],
      userStatus: doc.data()['user_status'],
      userStatusDate: doc.data()['user_status_date'],
      statusChangedBy: doc.data()['status_changed_by']);
}

Future<UserProfile> extractUserProfileForFirebaseUser(authLib.User user) async {
  try {
    if (user == null) return null;

    DocumentSnapshot userProfileDoc =
        await DataService.getUserProfile(user.uid);

    if (!userProfileDoc.exists) return null;

    UserProfile userProfile = mapFirebaseUserToUserProfile(userProfileDoc);
    userProfile.agencyName = await DataService.getAgencyNameByAgencyId(
            userProfileDoc.data()['agency_id'])
        .then((value) {
      return value.data()['name'];
    });

    return userProfile;
  } on Exception catch (e) {
    logInFireStore(message: e.toString(), logType: LogTypeEnum.Error);
    return null;
  }
}

enum LogTypeEnum {
  Info,
  Warning,
  Error,
}
Future<void> logInFireStore(
    {LogTypeEnum logType,
    String message,
    BuildContext context,
    String reportId}) {
  try {
    UserProfile userProfile;
    if (context != null) userProfile = Provider.of<UserProfile>(context);

    return FirebaseFirestore.instance.collection('logs').add({
      'log_type': logType,
      'message': message,
      'user_id': userProfile != null ? userProfile.userId : null,
      'report_id': reportId != null ? reportId : null,
      'time': DateTime.now(),
    });
  } on Exception catch (e) {
    print(e.toString());
    return null;
  }
}

class AuthService {
  // auth change user stream
  static Stream<UserProfile> get user {
    try {
      Stream<authLib.User> myStream =
          authLib.FirebaseAuth.instance.authStateChanges();
      return myStream
          .asyncMap((event) => extractUserProfileForFirebaseUser(event));
    } on Exception catch (e) {
      logInFireStore(message: e.toString(), logType: LogTypeEnum.Error);
      return null;
    }
  }

  // sign in with email and password
  static Future signInWithEmailAndPassword(
      String email, String password) async {
    OperationResult or = OperationResult();
    try {
      authLib.UserCredential result = await authLib.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      authLib.User user = result.user;

      or.operationCode = OperationResultCodeEnum.Success;
      or.content = user;
      return or;
    } on Exception catch (e) {
      String errMsg = e.toString();
      if (e is authLib.FirebaseAuthException) {
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

      or.operationCode = OperationResultCodeEnum.Error;
      or.message = errMsg;
      return or;
    }
  }

  // register with email and password
  static Future registerWithEmailAndPassword(String email, String password,
      String agencyId, String personName, String phoneNumber) async {
    OperationResult or = OperationResult();
    try {
      authLib.UserCredential result = await authLib.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // create a new document for the user with the uid
      or = await DataService.updateUserProfile(result.user.uid, agencyId,
          personName, phoneNumber, result.user.email);

      AuthService.signOut();

      return or;
    } on Exception catch (e) {
      String errMsg = e.toString();
      if (e is authLib.FirebaseAuthException) {
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

      or.operationCode = OperationResultCodeEnum.Error;
      or.message = errMsg;
      return or;
    }
  }

  // sign out
  static Future signOut() async {
    try {
      if (authLib.FirebaseAuth.instance.currentUser != null)
        await authLib.FirebaseAuth.instance.signOut();
    } catch (e) {
      throw e;
    }
  }
}

class DataService {
  static Future<DocumentSnapshot> getUserProfile(String uid) {
    try {
      return FirebaseFirestore.instance
          .collection('user_profile')
          .doc(uid)
          .get();
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<OperationResult> getPersonNameByUserId(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('user_profile')
          .doc(uid)
          .get();

      OperationResult or = OperationResult();
      or.operationCode = OperationResultCodeEnum.Success;
      or.content = doc.data()['person_name'];

      return or;
    } catch (e) {
      OperationResult or = OperationResult();
      or.operationCode = OperationResultCodeEnum.Error;
      or.content = 'Could not resolve person name';
      or.message = e.toString();
      return or;
    }
  }

  static Future<DocumentSnapshot> getAgencyNameByAgencyId(String agencyId) {
    try {
      return FirebaseFirestore.instance
          .collection('agency')
          .doc(agencyId)
          .get();
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<OperationResult> updateUserProfile(
      String userId,
      String agencyId,
      String personName,
      String phoneNumber,
      String email) async {
    OperationResult or = OperationResult();
    try {
      UserProfile userProfile = UserProfile(
        userId: userId,
        agencyId: agencyId,
        personName: personName,
        phoneNumber: phoneNumber,
        email: email,
        userCategory: UserCategoryBaseEnum.User.value,
        creationDate: Timestamp.fromDate(DateTime.now()),
        userStatus: false,
        userStatusDate: Timestamp.fromDate(DateTime.now()),
        statusChangedBy: 'system',
      );

      await FirebaseFirestore.instance
          .collection('user_profile')
          .doc(userId)
          .set({
        'agency_id': userProfile.agencyId,
        'person_name': userProfile.personName,
        'phone_number': userProfile.phoneNumber,
        'email': userProfile.email,
        'user_category': userProfile.userCategory,
        'creation_date': userProfile.creationDate,
        'user_status': userProfile.userStatus,
        'user_status_date': userProfile.userStatusDate,
        'status_changed_by': userProfile.statusChangedBy,
      });

      or.operationCode = OperationResultCodeEnum.Success;
      or.content = userProfile;

      return or;
    } on Exception catch (e) {
      or.operationCode = OperationResultCodeEnum.Error;
      or.message = e.toString();

      return or;
    }
  }

  static Future<OperationResult> updateUserStatus(
    String userId,
    bool userStatus,
    String changedBy,
  ) async {
    OperationResult or = OperationResult();
    try {
      await FirebaseFirestore.instance
          .collection('user_profile')
          .doc(userId)
          .update({
        'user_status': userStatus,
        'user_status_date': Timestamp.fromDate(DateTime.now()),
        'status_changed_by': changedBy,
      });

      or.operationCode = OperationResultCodeEnum.Success;

      return or;
    } on Exception catch (e) {
      or.operationCode = OperationResultCodeEnum.Error;
      or.message = e.toString();
      print(e.toString());

      return or;
    }
  }

  static Future<OperationResult> createReport(Report report) async {
    OperationResult or = OperationResult();
    try {
      DocumentReference ref =
          await FirebaseFirestore.instance.collection('report').add({
        'user_id': report.userId,
        'agency_id': report.agencyId,
        'time': report.time,
        'address': report.address,
        'location_geopoint': report.locationGeoPoint,
        'image_url': report.imageURL,
        'material': report.material,
        'diameter': report.diameter,
        'cause': report.cause
      });
      or.operationCode = OperationResultCodeEnum.Success;
      or.content = ref;

      return or;
    } catch (e) {
      or.operationCode = OperationResultCodeEnum.Error;
      or.message = e.toString();
      return or;
    }
  }

  static Future<OperationResult> updateReport(Report report) async {
    OperationResult or = OperationResult();
    try {
      await FirebaseFirestore.instance
          .collection('report')
          .doc(report.rid)
          .update({
        'time': report.time,
        'address': report.address,
        'location_geopoint': report.locationGeoPoint,
        'image_url': report.imageURL,
        'material': report.material,
        'diameter': report.diameter,
        'cause': report.cause
      });

      or.operationCode = OperationResultCodeEnum.Success;
      return or;
    } catch (e) {
      or.operationCode = OperationResultCodeEnum.Error;
      or.message = e.toString();
      return or;
    }
  }

  static deleteReport(String reportId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .doc(reportId)
          .delete();
    } catch (e) {
      throw e;
    }
  }

  // report list from snapshot
  static List<Report> _reportListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return Report(
            rid: doc.id,
            userId: doc.data()['user_id'],
            agencyId: doc.data()['agency_id'],
            time: doc.data()['time'],
            address: doc.data()['address'],
            locationGeoPoint: doc.data()['location_geopoint'],
            imageURL: doc.data()['image_url'],
            material: doc.data()['material'],
            diameter: doc.data()['diameter'],
            cause: doc.data()['cause']);
      }).toList();
    } on Exception catch (e) {
      throw e;
    }
  }

  // report data from snapshots
  static Report _reportFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return Report(
          rid: snapshot.id,
          userId: snapshot.data()['user_id'],
          agencyId: snapshot.data()['agency_id'],
          time: snapshot.data()['time'],
          address: snapshot.data()['address'],
          locationGeoPoint: snapshot.data()['location_geopoint'],
          imageURL: snapshot.data()['image_url'],
          material: snapshot.data()['material'],
          diameter: snapshot.data()['diameter'],
          cause: snapshot.data()['cause']);
    } on Exception catch (e) {
      throw e;
    }
  }

  // get reports stream
  static Stream<List<Report>> getReportsStream(String agencyId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .where('agency_id', isEqualTo: agencyId)
          .orderBy('time', descending: true)
          .snapshots()
          .map(_reportListFromSnapshot);
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<OperationResult> getUsersProfilesByAgencyId(
      String agencyId) async {
    OperationResult or = OperationResult();
    try {
      if (agencyId == null) {
        or.operationCode = OperationResultCodeEnum.Error;
        or.message = 'Agency id is null';
        or.content = List<UserProfile>();
        return or;
      }

      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('user_profile')
          .where('agency_id', isEqualTo: agencyId)
          .orderBy('email')
          .get();

      or.content =
          qs.docs.map((doc) => (mapFirebaseUserToUserProfile(doc))).toList();
      or.operationCode = OperationResultCodeEnum.Success;
      return or;
    } on Exception catch (e) {
      or.message = e.toString();
      or.operationCode = OperationResultCodeEnum.Error;
      return or;
    }
  }

  static Future<QuerySnapshot> getReportsSnapshot(String agencyId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .where('agency_id', isEqualTo: agencyId)
          .orderBy('time', descending: true)
          .get();
    } on Exception catch (e) {
      throw e;
    }
  }

  // get user doc stream
  static Future<Report> getReport(String docId) async {
    return FirebaseFirestore.instance
        .collection('report')
        .doc(docId)
        .get()
        .then((value) => _reportFromSnapshot(value))
        .catchError((error, stackTrace) {
      print("================inner: $error");
      return Future.error("");
    });
  }

  static Future<QuerySnapshot> get agencies {
    try {
      return FirebaseFirestore.instance.collection('agency').get();
      //.then((value) => value);
    } on Exception catch (e) {
      throw e;
    }
  }
}
