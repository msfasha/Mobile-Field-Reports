import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String userId;
  String agencyId;
  String agencyName;
  String personName;
  String phoneNumber;
  String email;
  String userCategory; //normal user, agency admin, system admin.
  Timestamp creationDate;
  bool userStatus;
  Timestamp userStatusDate;
  String statusChangedBy;

  UserProfile(
      {this.userId,
      this.agencyId,
      this.agencyName,
      this.personName,
      this.phoneNumber,
      this.email,
      this.userCategory, //normal user, agency admin, system admin.
      this.creationDate,
      this.userStatus, //true or false, activated and deactivated
      this.userStatusDate,
      this.statusChangedBy});
}
