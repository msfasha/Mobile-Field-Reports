import 'package:ufr/models/report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // collection reference
  final CollectionReference usersProfilesCollection =
      FirebaseFirestore.instance.collection('user_profile');
  final CollectionReference reportsCollection =
      FirebaseFirestore.instance.collection('report');
  final CollectionReference utilitiesCollection =
      FirebaseFirestore.instance.collection('utility');

  Future<DocumentSnapshot> getUserProfile(String uid) {
    try {
      return usersProfilesCollection.doc(uid).get();
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<QuerySnapshot> getUtilityByUtilityId(int utilityId) {
    try {
      return utilitiesCollection
          .where('utility_id', isEqualTo: utilityId)
          .get();
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<void> updateUserProfile(
      String userId, int utilityId, String personName) {
    try {
      return usersProfilesCollection.doc(userId).set({
        'utility_id': utilityId,
        'person_name': personName,
      });
    } on Exception catch (e) {
      throw e;
    }
  }

  dynamic createReport(Report report) {
    try {
      return reportsCollection.add({
        'user_id': report.userId,
        'utility_id': report.utilityId,
        'time': report.time,
        'address': report.address,
        'location_geopoint': report.locationGeoPoint,
        'material': report.material,
        'diameter': report.diameter,
        'cause': report.cause
      });
    } catch (e) {
      throw e;
    }
  }

  dynamic updateReport(Report report) {
    try {
      return reportsCollection.doc(report.rid).update({
        'time': report.time,
        'address': report.address,
        'location_geopoint': report.locationGeoPoint,
        'material': report.material,
        'diameter': report.diameter,
        'cause': report.cause
      });
    } catch (e) {
      throw e;
    }
  }

  deleteReport(String reportId) {
    try {
      return reportsCollection.doc(reportId).delete();
    } catch (e) {
      throw e;
    }
  }

  // report list from snapshot
  List<Report> _reportListFromSnapshot(QuerySnapshot snapshot) {
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
  Report _reportFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return Report(
          rid: snapshot.data()['id'] ?? '',
          userId: snapshot.data()['user_id'] ?? '',
          utilityId: snapshot.data()['utility_id'] ?? '',
          time: snapshot.data()['time'] ?? '',
          address: snapshot.data()['address'] ?? '',
          locationGeoPoint: snapshot.data()['location_geopoint'] ?? null,
          material: snapshot.data()['material'] ?? '',
          diameter: snapshot.data()['diameter'] ?? '',
          cause: snapshot.data()['cause'] ?? '');
    } on Exception catch (e) {
      throw e;
    }
  }

  // get reports stream
  Stream<List<Report>> getReports(int utilityId) {
    try {
      return reportsCollection
          .where('utility_id', isEqualTo: utilityId)
          .orderBy('time', descending: true)
          .snapshots()
          .map(_reportListFromSnapshot);
    } on Exception catch (e) {
      throw e;
    }
  }

  // get user doc stream
  Future<Report> getReport(String docId) async {
    try {
      return reportsCollection
          .doc(docId)
          .get()
          .then((value) => _reportFromSnapshot(value));
    } on Exception catch (e) {
      throw e;
    }
  }

  Future<QuerySnapshot> get utilities {
    try {
      return utilitiesCollection.get().then((value) => value);
    } on Exception catch (e) {
      throw e;
    }
  }  
}
