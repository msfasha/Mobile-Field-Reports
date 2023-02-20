import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../models/user_profile.dart';
import 'modules.dart';

enum LogTypeEnum {
  info,
  warning,
  error,
}

class DataService {
  static Future<DocumentSnapshot> getUserProfile(String uid) {
    try {
      return FirebaseFirestore.instance
          .collection('user_profile')
          .doc(uid)
          .get();
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getPersonNameByUserId(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('user_profile')
          .doc(uid)
          .get();

      return doc['person_name'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> getAgencyNameByAgencyId(String agencyId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('agency')
          .doc(agencyId)
          .get();

      return doc['name'];
    } catch (e) {
      rethrow;
    }
  }

  static Future<UserProfile> updateUserProfile(String userId, String agencyId,
      String personName, String phoneNumber, String email) async {
    try {
      UserProfile userProfile = UserProfile(
        userId: userId,
        agencyId: agencyId,
        personName: personName,
        phoneNumber: phoneNumber,
        email: email,
        userCategory: UserCategoryBaseEnum.user.value,
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

      return userProfile;
    } catch (e) {
      rethrow;
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

      or.operationCode = OperationResultCodeEnum.success;

      return or;
    } catch (e) {
      or.operationCode = OperationResultCodeEnum.error;
      or.message = e.toString();
      if (kDebugMode) {
        print(e.toString());
      }

      return or;
    }
  }

  static Future<void> createReport(ReportCls report) async {
    try {
      //DocumentReference ref =
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
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateReport(ReportCls report) async {
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
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteReport(String reportId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .doc(reportId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // report list from snapshot
  static List<ReportCls> _reportListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        return ReportCls(
            rid: doc.id,
            userId: doc['user_id'],
            agencyId: doc['agency_id'],
            time: doc['time'],
            address: doc['address'],
            locationGeoPoint: doc['location_geopoint'],
            imageURL: doc['image_url'],
            material: doc['material'],
            diameter: doc['diameter'],
            cause: doc['cause']);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // report data from snapshots
  // static Report _reportFromSnapshot(DocumentSnapshot snapshot) {
  //   try {
  //     return Report(
  //         rid: snapshot.id,
  //         userId: snapshot['user_id'],
  //         agencyId: snapshot['agency_id'],
  //         time: snapshot['time'],
  //         address: snapshot['address'],
  //         locationGeoPoint: snapshot['location_geopoint'],
  //         imageURL: snapshot['image_url'],
  //         material: snapshot['material'],
  //         diameter: snapshot['diameter'],
  //         cause: snapshot['cause']);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // get reports stream
  static Stream<List<ReportCls>> getReportsStream(String agencyId) {
    try {
      return FirebaseFirestore.instance
          .collection('report')
          .where('agency_id', isEqualTo: agencyId)
          .orderBy('time', descending: true)
          .snapshots()
          .map(_reportListFromSnapshot);
    } catch (e) {
      rethrow;
    }
  }

  static Future<OperationResult> getUsersProfilesByAgencyId(
      String? agencyId) async {
    OperationResult or = OperationResult();
    try {
      // if (agencyId == null) {
      //   or.operationCode = OperationResultCodeEnum.error;
      //   or.message = 'Agency id is null';
      //   or.content = List<UserProfile>();
      //   return or;
      // }

      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('user_profile')
          .where('agency_id', isEqualTo: agencyId)
          .orderBy('email')
          .get();

      or.content =
          qs.docs.map((doc) => (mapFirebaseUserToUserProfile(doc))).toList();
      or.operationCode = OperationResultCodeEnum.success;
      return or;
    } catch (e) {
      or.message = e.toString();
      or.operationCode = OperationResultCodeEnum.error;
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
    } catch (e) {
      rethrow;
    }
  }

  // get user doc stream
  // static Future<Report> getReport(String docId) async {
  //   return FirebaseFirestore.instance
  //       .collection('report')
  //       .doc(docId)
  //       .get()
  //       .then((value) => _reportFromSnapshot(value))
  //       .catchError((error, stackTrace) {
  //     if (kDebugMode) {
  //       print("================inner: $error");
  //     }
  //     return Future.error("");
  //   });
  // }

  static Future<QuerySnapshot> get agencies {
    try {
      return FirebaseFirestore.instance.collection('agency').get();
      //.then((value) => value);
    } catch (e) {
      rethrow;
    }
  }
}

UserProfile mapFirebaseUserToUserProfile(DocumentSnapshot doc) {
  return UserProfile(
      userId: doc.id,
      agencyId: doc['agency_id'],
      personName: doc['person_name'],
      phoneNumber: doc['phone_number'],
      email: doc['email'],
      userCategory: doc['user_category'],
      creationDate: doc['creation_date'],
      userStatus: doc['user_status'],
      userStatusDate: doc['user_status_date'],
      statusChangedBy: doc['status_changed_by'],
      agencyName: ''); //agencyName is added because it is defined as mandatory
}

Future<void> logInFireStore(
    {required LogTypeEnum logType,
    required dynamic exception,
    StackTrace? stacktrace,
    required String source,
    required String message,
    required BuildContext context,
    required String reportId}) async {
  try {
    int errorCount = 1;
    String strippedStackTrace;
    String hashCode;
    String? docId; //will be used if we need to update an existing document

    UserProfile userProfile;
    userProfile = Provider.of<UserProfile>(context, listen: false);

//prepare document, if the error is repeated, informaton about the last
//error will overwrite the previous error details i.e. time, source, user...etc,
//and the error count will be incremented
    Map<String, dynamic> logDoc = {
      'time': DateTime.now(),
      'log_type': logType.toString(),
      'exception': exception?.toString(),
      'exception object type': exception?.runtimeType.toString(),
      'stripped_stack_trace': null,
      'stack_trace': null,
      'hash_code': null,
      'error_count': 1,
      'source': source,
      'message': message,
      'user_email': userProfile.email,
      'user_agency': userProfile.agencyName,
      'report_id': reportId,
    };

    //calculate the hash code for the stacktrace, and check if this error is already registered.
    //if it is already registered, then just increment the error count.
    if (stacktrace != null) {
      //just take the first line of the stack trace, usually this contains the name of the code unit
      List<String> splitStackTrace = stacktrace.toString().split('#');
      splitStackTrace.remove("");
      strippedStackTrace = splitStackTrace.getRange(0, 4).toString();
      hashCode = md5.convert(utf8.encode(strippedStackTrace)).toString();

      //store a splitted version of the full stack trace, for debugging purposes
      logDoc.update('stack_trace', (value) {
        return splitStackTrace;
      });

      //set the stripped stack trace value
      logDoc.update('stripped_stack_trace', (value) {
        return strippedStackTrace;
      });
      //update the initial hashcode
      logDoc.update('hash_code', (value) {
        return hashCode;
      });

      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('logs')
          .where('hash_code', isEqualTo: hashCode)
          .get();

      //check if this document/hashcode is already stored
      if (qs.size > 0) {
        //get the document id so that we can update this document later
        docId = qs.docs[0].id;

        //since this error is already registered, just increase the counter
        errorCount = qs.docs[0]['error_count'] + 1;

        //update/increment the existing error counter
        logDoc.update('error_count', (value) {
          return errorCount;
        });
      }
    }

    if (docId != null) {
      await FirebaseFirestore.instance
          .collection('logs')
          .doc(docId)
          .update(logDoc);
    } else {
      await FirebaseFirestore.instance.collection('logs').add(logDoc);
    }

    if (kDebugMode) {
      print('..... error logged in firebase.');
    }
  } catch (e) {
    if (kDebugMode) {
      print('..... logger error: $e');
    }
  }
}
