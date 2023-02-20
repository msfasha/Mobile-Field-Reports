import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/shared/globals.dart';

class ReportMapListing extends StatefulWidget {
  const ReportMapListing({super.key});
  @override
  State<ReportMapListing> createState() => ReportMapListingState();
}

class ReportMapListingState extends State<ReportMapListing> {
  //Location location = new Location();
  final Set<Marker> _markers = HashSet<Marker>();
  final Completer<GoogleMapController> _controller = Completer();
  late CameraPosition _cameraPosition;

  @override
  void initState() {
    _setInitialCameraPosition();
    //_checkLocationPermission();
    super.initState();
  }

  void _setInitialCameraPosition() {
    //zoom over Jordan
    _cameraPosition = const CameraPosition(
      target: LatLng(31.9, 35.9),
      zoom: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    _markers.clear();

    final reports = Provider.of<List<ReportCls>>(context);

    for (var report in reports) {
      if (report.locationGeoPoint != null) {
        _markers.add(Marker(
            markerId: MarkerId(report.rid!),
            position: LatLng(report.locationGeoPoint!.latitude,
                report.locationGeoPoint!.longitude)));
      }
    }

    return GoogleMap(
      mapType: MapType.normal,
      myLocationButtonEnabled: Globals.locationPerissionGranted,
      myLocationEnabled: Globals.locationPerissionGranted,
      initialCameraPosition: _cameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: _markers,
      onTap: (point) {},
    );
  }
}
