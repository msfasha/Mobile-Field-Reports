import 'package:ufr/models/report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as authLib;
import 'package:ufr/models/user.dart';

class TestService
{
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

  static Future<String> timedelay()  {
    return Future.delayed(Duration(milliseconds: 2000))
        .then((value) => ('second then finished'));
  }
  //********************************************************
}
class AuthService {
  static Future<User> _userFromFirebaseUser(authLib.User user) async {
    try {
      if (user == null) return null;

      DocumentSnapshot userDoc = await DatabaseService.getUserProfile(user.uid);

      if (userDoc.exists)
        return User(
            userId: user.uid,
            utilityId: userDoc.data()['utility_id'],
            utilityName: await DatabaseService.getUtilityByUtilityId(
                    userDoc.data()['utility_id'])
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
  static Stream<User> get user {
    try {
      Stream<authLib.User> myStream =
          authLib.FirebaseAuth.instance.authStateChanges();
      return myStream.asyncMap((event) => _userFromFirebaseUser(event));
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
      return _userFromFirebaseUser(user);
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
  static Future registerWithEmailAndPassword(
      String email, String password, int utilityId, String personName) async {
    try {
      authLib.UserCredential result = await authLib.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // create a new document for the user with the uid
      DatabaseService.updateUserProfile(result.user.uid, utilityId, personName);

      return _userFromFirebaseUser(result.user);
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

class DatabaseService {
 

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

  static Future<QuerySnapshot> getUtilityByUtilityId(int utilityId) {
    try {
      return FirebaseFirestore.instance
          .collection('utility')
          .where('utility_id', isEqualTo: utilityId)
          .get();
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<void> updateUserProfile(
      String userId, int utilityId, String personName) {
    try {
      return FirebaseFirestore.instance
          .collection('user_profile')
          .doc(userId)
          .set({
        'utility_id': utilityId,
        'person_name': personName,
      });
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<DocumentReference> createReport(Report report) {
    return FirebaseFirestore.instance.collection('report').add({
      'user_id': report.userId,
      'utility_id': report.utilityId,
      'time': report.time,
      'address': report.address,
      'location_geopoint': report.locationGeoPoint,
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
            utilityId: doc.data()['utility_id'],
            time: doc.data()['time'],
            address: doc.data()['address'],
            locationGeoPoint: doc.data()['location_geopoint'],
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
          utilityId: snapshot.data()['utility_id'],
          time: snapshot.data()['time'],
          address: snapshot.data()['address'],
          locationGeoPoint: snapshot.data()['location_geopoint'],
          material: snapshot.data()['material'],
          diameter: snapshot.data()['diameter'],
          cause: snapshot.data()['cause']);
    } on Exception catch (e) {
      throw e;
    }
  }

  // get reports stream
  static Stream<List<Report>> getReportsStream(int utilityId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .where('utility_id', isEqualTo: utilityId)
          .orderBy('time', descending: true)
          .snapshots()
          .map(_reportListFromSnapshot);
    } on Exception catch (e) {
      throw e;
    }
  }

  static Future<QuerySnapshot> getReportsSnapshot(int utilityId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .where('utility_id', isEqualTo: utilityId)
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

  static Future<QuerySnapshot> get utilities {
    try {
      return FirebaseFirestore.instance
          .collection('utility')
          .get()
          .then((value) => value);
    } on Exception catch (e) {
      throw e;
    }
  }
}
