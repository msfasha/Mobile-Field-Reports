import 'package:cloud_firestore/cloud_firestore.dart';

class ReportCls {
  String? rid;
  String userId;
  String agencyId;
  Timestamp time;
  String? address;
  GeoPoint? locationGeoPoint;
  String? imageURL;
  String? material;
  int? diameter;
  String? cause;

  ReportCls(
      {this.rid,
      required this.userId,
      required this.agencyId,
      required this.time,
      this.address,
      this.locationGeoPoint,
      this.imageURL,
      this.material,
      this.diameter,
      this.cause});
}
