import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/shared/modules.dart';

enum SelectMapPointUseModeEnum { allowSelect, noSelect }

class SelectMapPoint extends StatefulWidget {
  final GeoPoint? initialGeoPoint;
  final SelectMapPointUseModeEnum useMode;

  const SelectMapPoint(
      {super.key, this.initialGeoPoint, required this.useMode});

  @override
  State<SelectMapPoint> createState() => SelectMapPointState();
}

class SelectMapPointState extends State<SelectMapPoint> {
  final Set<Marker> _markers = HashSet<Marker>();
  final Completer<GoogleMapController> _controller = Completer();
  late CameraPosition _cameraPosition;
  GeoPoint? _selectedGeoPoint;

  @override
  void initState() {
    _setInitialCameraPosition();
    super.initState();
  }

  void _setInitialCameraPosition() {
    if (widget.initialGeoPoint != null) {
      _cameraPosition = (CameraPosition(
        target: LatLng(widget.initialGeoPoint!.latitude,
            widget.initialGeoPoint!.longitude),
        zoom: 17,
      ));
      _markers.add(Marker(
          markerId: const MarkerId("report_location"),
          position: LatLng(widget.initialGeoPoint!.latitude,
              widget.initialGeoPoint!.longitude)));
    } else {
      //just zoom over Jordan
      _cameraPosition = const CameraPosition(
        target: LatLng(31.9, 35.9),
        zoom: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            myLocationButtonEnabled: Globals.locationPerissionGranted,
            myLocationEnabled: Globals.locationPerissionGranted,
            initialCameraPosition: _cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: _markers,
            onTap: (point) {
              if (widget.useMode == SelectMapPointUseModeEnum.allowSelect) {
                setState(() {
                  _markers.clear();
                  _markers.add(Marker(
                      markerId: const MarkerId("report_location"),
                      position: point));
                  _selectedGeoPoint = GeoPoint(point.latitude, point.longitude);
                });
              }
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: widget.useMode == SelectMapPointUseModeEnum.allowSelect
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          ElevatedButton(
                              onPressed: () {
                                if (_selectedGeoPoint == null) {
                                  if (context.mounted) {
                                    showSnackBarMessage(
                                        context, 'No point selected');
                                    Navigator.pop(context);
                                  }
                                } else {
                                  Navigator.pop(context, _selectedGeoPoint);
                                }
                              },
                              child: const Text(
                                'Ok',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ))
                        ])
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ))),
        ],
      ),
    );
  }
}
