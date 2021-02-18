import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/shared/modules.dart';

enum SelectMapPointUseModeEnum { AllowSelect, NoSelect }

class SelectMapPoint extends StatefulWidget {
  final GeoPoint selectedGeoPoint;
  final SelectMapPointUseModeEnum useMode;

  SelectMapPoint({this.selectedGeoPoint, this.useMode});

  @override
  State<SelectMapPoint> createState() =>
      SelectMapPointState(selectedGeoPoint: selectedGeoPoint);
}

class SelectMapPointState extends State<SelectMapPoint> {
  GeoPoint selectedGeoPoint;
  Set<Marker> _markers = HashSet<Marker>();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition;

  SelectMapPointState({this.selectedGeoPoint});

  @override
  void initState() {
    _setInitialCameraPosition();
    super.initState();
  }

  void _setInitialCameraPosition() {
    if (selectedGeoPoint != null) {
      _cameraPosition = (CameraPosition(
        target: LatLng(selectedGeoPoint.latitude, selectedGeoPoint.longitude),
        zoom: 17,
      ));
      _markers.add(Marker(
          markerId: MarkerId("report_location"),
          position:
              LatLng(selectedGeoPoint.latitude, selectedGeoPoint.longitude)));
    } else {
      //just zoom over Jordan
      _cameraPosition = CameraPosition(
        target: LatLng(31.9, 35.9),
        zoom: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: customMapScafoldKey,
      appBar: AppBar(
        title: Text('Select Location'),
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
              if (widget.useMode == SelectMapPointUseModeEnum.AllowSelect) {
                setState(() {
                  _markers.clear();
                  _markers.add(Marker(
                      markerId: MarkerId("report_location"), position: point));
                  selectedGeoPoint = GeoPoint(point.latitude, point.longitude);
                });
              }
            },
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: widget.useMode == SelectMapPointUseModeEnum.AllowSelect
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                          RaisedButton(
                              color: Colors.black54,
                              onPressed: () {
                                if (selectedGeoPoint == null) {
                                  showSnackBarMessage(
                                      'No point selected', customMapScafoldKey);
                                } else
                                  Navigator.pop(context, selectedGeoPoint);
                              },
                              child: Text(
                                'Ok',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          RaisedButton(
                              color: Colors.black54,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ))
                        ])
                  : RaisedButton(
                      color: Colors.black54,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ))),
        ],
      ),
    );
  }
}
