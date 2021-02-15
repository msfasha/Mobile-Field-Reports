import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String rid;
  String userId;
  String agencyId;
  Timestamp time;
  String address;
  GeoPoint locationGeoPoint;
  String imageURL;
  String material;
  int diameter;
  String cause;

  Report(
      {this.rid,
      this.userId,
      this.agencyId,
      this.time,
      this.address,
      this.locationGeoPoint,
      this.imageURL,
      this.material,
      this.diameter,
      this.cause});
}
