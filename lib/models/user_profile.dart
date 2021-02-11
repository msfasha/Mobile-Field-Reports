import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String userId;
  String organizationId;
  String organizationName;
  String personName;
  String phoneNumber;
  String email;
  String userCategory; //normal user, organization admin, system admin.
  Timestamp creationDate;
  bool userStatus;
  Timestamp userStatusDate;
  String statusChangedBy;

  UserProfile(
      {this.userId,
      this.organizationId,
      this.organizationName,
      this.personName,
      this.phoneNumber,
      this.email,
      this.userCategory, //normal user, organization admin, system admin.
      this.creationDate,
      this.userStatus, //true or false, activated and deactivated
      this.userStatusDate,
      this.statusChangedBy});
}
