import 'package:cloud_firestore/cloud_firestore.dart';
class Report {
  String rid;
  String userId;
  int utilityId;
  Timestamp time;
  String address;
  GeoPoint locationGeoPoint;
  String material;
  int diameter;
  String cause;

  Report(
      {this.rid,
      this.userId,
      this.utilityId,
      this.time,
      this.address,
      this.locationGeoPoint,
      this.material,
      this.diameter,
      this.cause});
}
