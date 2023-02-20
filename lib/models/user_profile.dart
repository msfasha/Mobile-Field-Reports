import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  String userId;
  String agencyId;
  String? agencyName; //value is retreived at runtime based in agency id
  String personName;
  String phoneNumber;
  String email;
  String userCategory; //normal user, agency admin, system admin.
  Timestamp creationDate;
  bool userStatus;
  Timestamp userStatusDate;
  String statusChangedBy;

  UserProfile(
      {required this.userId,
      required this.agencyId,
      this.agencyName,
      required this.personName,
      required this.phoneNumber,
      required this.email,
      required this.userCategory, //normal user, agency admin, system admin.
      required this.creationDate,
      required this.userStatus, //true or false, activated and deactivated
      required this.userStatusDate,
      required this.statusChangedBy});
}
