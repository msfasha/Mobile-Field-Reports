import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String rid;
  String userId;
  String organizationId;
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
      this.organizationId,
      this.time,
      this.address,
      this.locationGeoPoint,
      this.imageURL,
      this.material,
      this.diameter,
      this.cause});
}
