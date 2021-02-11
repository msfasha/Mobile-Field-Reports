import 'package:ufr/models/report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as authLib;
import 'package:ufr/models/user_profile.dart';

class TestService {
  //******************************************************** */
  static Future<String> deleteRecord() {
    return Future.delayed(Duration(milliseconds: 2000))
        .then((value) => ('then finished'));

    //timedelay();
    //return 'Done';
    //.then((value) => value); //.then((value) => value);
    //return ''; //.then((value) => 'Done from then');
    //return ('Done');
  }

  static String myMethod() {
    timedelay();
    return 'Done';
    //.then((value) => value); //.then((value) => value);
    //return ''; //.then((value) => 'Done from then');
    //return ('Done');
  }

  static Future<String> timedelay() {
    return Future.delayed(Duration(milliseconds: 2000))
        .then((value) => ('second then finished'));
  }
  //********************************************************
}

class AuthService {
  static Future<UserProfile> getUserProfileFromFirebaseUser(
      authLib.User user) async {
    try {
      if (user == null) return null;

      DocumentSnapshot userProfileDoc =
          await DataService.getUserProfile(user.uid);

      if (userProfileDoc.exists)
        return UserProfile(
            userId: user.uid,
            organizationId: userProfileDoc.data()['organization_id'],
            organizationName: await DataService.getOrganizationByOrganizationId(
                    userProfileDoc.data()['organization_id'])
                .then((value) {
              return value.data()['name'];
            }),
            personName: userProfileDoc.data()['person_name'],
            phoneNumber: userProfileDoc.data()['phone_number'],
            email: user.email,
            userCategory: userProfileDoc.data()['user_category'],
            creationDate: userProfileDoc.data()['creation_date'],
            userStatus: userProfileDoc.data()['user_status'],
            userStatusDate: userProfileDoc.data()['user_status_date'],
            statusChangedBy: userProfileDoc.data()['status_changed_by']);
      else
        return null;
    } on Exception catch (e) {
      throw e;
    }
  }

  // auth change user stream
  static Stream<UserProfile> get user {
    try {
      print('auth changed');
      Stream<authLib.User> myStream =
          authLib.FirebaseAuth.instance.authStateChanges();
      return myStream
          .asyncMap((event) => getUserProfileFromFirebaseUser(event));
    } on Exception catch (e) {
      throw e;
    }
  }

  // sign in anon
  static Future signInAnon() async {
    try {
      authLib.UserCredential result =
          await authLib.FirebaseAuth.instance.signInAnonymously();
      authLib.User user = result.user;
      return getUserProfileFromFirebaseUser(user);
    } catch (e) {
      throw e;
    }
  }

  // sign in with email and password
  static Future signInWithEmailAndPassword(
      String email, String password) async {
    try {
      authLib.UserCredential result = await authLib.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      authLib.User user = result.user;
      return user;
    } catch (e) {
      throw e;
    }
  }

  // register with email and password
  static Future registerWithEmailAndPassword(String email, String password,
      String organizationId, String personName, String phoneNumber) async {
    try {
      authLib.UserCredential result = await authLib.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // create a new document for the user with the uid
      DataService.updateUserProfile(
          result.user.uid, organizationId, personName, phoneNumber);

      return getUserProfileFromFirebaseUser(result.user);
    } on Exception catch (e) {
      throw e;
    }
  }

  // sign out
  static Future signOut() async {
    try {
      return await authLib.FirebaseAuth.instance.signOut();
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

  static Future<DocumentSnapshot> getOrganizationByOrganizationId(
      String organizationId) {
    try {
      return FirebaseFirestore.instance
          .collection('organization')
          .doc(organizationId)
          .get();
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<void> updateUserProfile(String userId, String organizationId,
      String personName, String phoneNumber) {
    try {
      return FirebaseFirestore.instance
          .collection('user_profile')
          .doc(userId)
          .set({
        'organization_id': organizationId,
        'person_name': personName,
        'phone_number': phoneNumber,
        'user_category': 'normal',
        'creation_date': DateTime.now(),
        'user_status': false,
        'user_status_date': DateTime.now(),
        'status_changed_by': 'system',
      });
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<DocumentReference> createReport(Report report) {
    return FirebaseFirestore.instance.collection('report').add({
      'user_id': report.userId,
      'organization_id': report.organizationId,
      'time': report.time,
      'address': report.address,
      'location_geopoint': report.locationGeoPoint,
      'image_url': report.imageURL,
      'material': report.material,
      'diameter': report.diameter,
      'cause': report.cause
    });
  }

  static Future<void> updateReport(Report report) {
    return FirebaseFirestore.instance
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
            organizationId: doc.data()['organization_id'],
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
          organizationId: snapshot.data()['organization_id'],
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
  static Stream<List<Report>> getReportsStream(String organizationId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .where('organization_id', isEqualTo: organizationId)
          .orderBy('time', descending: true)
          .snapshots()
          .map(_reportListFromSnapshot);
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<QuerySnapshot> getReportsSnapshot(String organizationId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .where('organization_id', isEqualTo: organizationId)
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

  static Future<QuerySnapshot> get organizations {
    try {
      return FirebaseFirestore.instance.collection('organization').get();
      //.then((value) => value);
    } on Exception catch (e) {
      throw e;
    }
  }
}
