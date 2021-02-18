import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/display_image.dart';
import 'package:ufr/screens/home/select_map_point.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';

enum imageStatusEnum {
  NoImage,
  NewImageCaptured,
  ExistingImage,
}

class ReportDisplay extends StatefulWidget {
  final Report report;
  final String personName;

  ReportDisplay({this.report, this.personName});

  @override
  _ReportDisplayState createState() => _ReportDisplayState();
}

class _ReportDisplayState extends State<ReportDisplay> {
  bool _loadingEffect = false;

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
        key: reportFormScaffoldKey,
        appBar: AppBar(
          title: Text('Report Information'),
          elevation: 0.0,
        ),
        body: _loadingEffect == true
            ? Loading()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(children: [
                  Align(
                    child: Text(
                      'Report Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                      DateFormat('yyyy-MM-dd – kk:mm')
                          .format(widget.report.time.toDate()),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Address',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.address,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Cause',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.cause,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Diameter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.diameter.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Text(
                          widget.report.locationGeoPoint == null
                              ? ''
                              : widget.report.locationGeoPoint.latitude
                                      .toString() +
                                  " , " +
                                  widget.report.locationGeoPoint.longitude
                                      .toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: Icon(Icons.gps_fixed),
                          onPressed: () {
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectMapPoint(
                                          selectedGeoPoint:
                                              widget.report.locationGeoPoint,
                                          useMode: SelectMapPointUseModeEnum
                                              .NoSelect,
                                        )),
                              );
                            } catch (e) {
                              showSnackBarMessage(
                                  'error occured: ' + e.toString(),
                                  homeScaffoldKey);
                            }
                          }),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Material',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.material,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  widget.report.imageURL != null
                      ? IconButton(
                          icon: Icon(Icons.image),
                          onPressed: () async {
                            try {
                              setState(() => _loadingEffect = true);
                              File file =
                                  await downloadFile(widget.report.imageURL);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DisplayImage(file)));
                              setState(() => _loadingEffect = false);
                            } catch (e) {
                              setState(() => _loadingEffect = false);
                              showSnackBarMessage(
                                  'error occured: ' + e.toString(),
                                  homeScaffoldKey);
                            }
                          })
                      : Text('No image attached to this report',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'User name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(widget.personName,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                          child: Text(
                            'Close',
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                ]),
              ));
  }
}
