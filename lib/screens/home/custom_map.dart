import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class CustomMap extends StatefulWidget {
  final GeoPoint selectedGeoPoint;

  CustomMap({this.selectedGeoPoint});

  @override
  State<CustomMap> createState() =>
      CustomMapState(selectedGeoPoint: selectedGeoPoint);
}

class CustomMapState extends State<CustomMap> {
  GeoPoint selectedGeoPoint;
  Location location = new Location();
  Set<Marker> _markers = HashSet<Marker>();
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _cameraPosition;

  CustomMapState({this.selectedGeoPoint});

  @override
  void initState() {    
    _setInitialCameraPosition();
    _checkLocationPermission();
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

  void _checkLocationPermission() async {
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    //LocationData _selectedLocation = await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Location'),
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
        ),
        body: Builder(
          builder: (context) => Stack(
            children: <Widget>[
              GoogleMap(
                mapType: MapType.normal,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: _cameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                markers: _markers,
                onTap: (point) {
                  setState(() {
                    _markers.clear();
                    _markers.add(Marker(
                        markerId: MarkerId("report_location"),
                        position: point));
                    selectedGeoPoint =
                        GeoPoint(point.latitude, point.longitude);
                  });
                },
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                            color: Colors.black54,
                            onPressed: () {
                              if (selectedGeoPoint == null) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text('No point selected'),
                                  duration: Duration(milliseconds: 1500),
                                ));
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
                            )),
                      ])),
            ],
          ),
        ));
  }
}
