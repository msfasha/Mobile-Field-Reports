import 'package:cloud_firestore/cloud_firestore.dart';
class Report {
  final String rid;
  final String userId;
  final int utilityId;
  final Timestamp time;
  final String address;
  final GeoPoint locationGeoPoint;
  final String material;
  final int diameter;
  final String cause;

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
