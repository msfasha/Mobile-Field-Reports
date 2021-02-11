import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/custom_map.dart';
import 'package:provider/provider.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/shared/modules.dart';

import 'display_image.dart';

enum imageStatusEnum {
  NoImage,
  NewImageCaptured,
  ExistingImage,
}

class ReportForm extends StatefulWidget {
  final Report report;

  ReportForm({this.report});

  @override
  _ReportFormState createState() => _ReportFormState(report);
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final Report _report;
  imageStatusEnum _imageStatus = imageStatusEnum.NoImage;
  CrudOperationTypeEnum _crudOperationType;

  Timestamp _reportTimeStamp = Timestamp.fromDate(DateTime.now());

  String _reportAddress;
  TextEditingController _reportAddressController = new TextEditingController();
  GeoPoint _reportLocationGeoPoint;
  String _reportImageURL;
  String _reportMaterial;
  int _reportDiameter;
  String _reportCause;

  String _reportLocationGpsString;
  PickedFile _capturedFile;

  _ReportFormState(this._report);

  @override
  void initState() {
    if (_report != null) {
      _displayExistingReport(_report);
      _crudOperationType = CrudOperationTypeEnum.Update;
    } else {
      _crudOperationType = CrudOperationTypeEnum.Create;
    }
    super.initState();
  }

  @override
  void dispose() {
    _reportAddressController?.dispose();
    super.dispose();
  }

  void _displayExistingReport(Report report) {
    setState(() {
      _reportTimeStamp = report.time;

      _reportAddressController.text = report.address;
      _reportAddress = report.address;

      _reportLocationGeoPoint = report.locationGeoPoint;
      _reportLocationGpsString = _reportLocationGeoPoint != null
          ? report.locationGeoPoint.latitude.toString() +
              " , " +
              report.locationGeoPoint.longitude.toString()
          : 'Select location from map';

      _reportImageURL = report.imageURL;
      _imageStatus = report.imageURL != null
          ? imageStatusEnum.ExistingImage
          : imageStatusEnum.NoImage;

      if (Globals.materialList.contains(report.material))
        _reportMaterial = report.material;

      if (Globals.diameterList.contains(report.diameter))
        _reportDiameter = report.diameter;

      if (Globals.causeList.contains(report.cause)) _reportCause = report.cause;
    });
  }

  _saveReport(GlobalKey<FormState> _key) async {
    if (_key.currentState.validate()) {
      final user = Provider.of<UserProfile>(context, listen: false);

      String storagePath;
      if (_capturedFile != null) storagePath = await _uploadImage();

      Report report = Report(
          userId: user.userId,
          organizationId: user.organizationId,
          time: _reportTimeStamp,
          address: _reportAddress,
          locationGeoPoint: _reportLocationGeoPoint,
          imageURL: storagePath,
          material: _reportMaterial,
          diameter: _reportDiameter,
          cause: _reportCause);

      if (_crudOperationType == CrudOperationTypeEnum.Create) {
        DataService.createReport(report).then((value) {}).catchError((e) {
          showSnackBarMessage(
              'Error Occured: ${e.toString()}', reportFormScaffoldKey);
        });
      } else {
        report.rid = _report.rid;
        DataService.updateReport(report).then((value) {}).catchError((e) {
          showSnackBarMessage(
              'Error Occured: ${e.toString()}', reportFormScaffoldKey);
        });
      }

      showSnackBarMessage('Report successfully saved', reportFormScaffoldKey);
      Navigator.pop(context);
    }
  }

  void _selectLocationFromMap(BuildContext context) async {
    try {
      PermissionStatus locationPermissionStatus =
          await Permission.location.status;

      if (locationPermissionStatus != PermissionStatus.granted) {
        locationPermissionStatus = await Permission.location.request();

        if (locationPermissionStatus != PermissionStatus.granted)
          showSnackBarMessage(
              'No permission to use location services', reportFormScaffoldKey);
      } //My location button will be disabled

      // PermissionStatus locationPermissionStatus =
      //     await Permission.location.status;
      final GeoPoint result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CustomMap(
                selectedGeoPoint: _reportLocationGeoPoint,
                locationPermissionStatus: locationPermissionStatus)),
      );

      if (result != null) {
        setState(() {
          _reportLocationGeoPoint = result;
          _reportLocationGpsString =
              result.latitude.toString() + " , " + result.longitude.toString();
        });
      }
    } on Exception catch (e) {
      showSnackBarMessage(e.toString(), reportFormScaffoldKey);
    }
  }

  Future<String> _uploadImage() async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('ufr/')
          .child('${_capturedFile.path.split('/').last}');

      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': _capturedFile.path});

      await ref.putFile(File(_capturedFile.path), metadata);

      return ref.fullPath;
    } on Exception catch (e) {
      showSnackBarMessage(e.toString(), reportFormScaffoldKey);
      return null;
    }
  }

  _toggleCameraGallerySelection(ImageCapturingMethodEnum imageCapturingMethod,
      String organizationId) async {
    try {
      var capturedFile;

      if (imageCapturingMethod == ImageCapturingMethodEnum.Camera) {
        capturedFile = await ImagePicker().getImage(
            source: ImageSource.camera,
            imageQuality: 50,
            maxHeight: 480,
            maxWidth: 640);
      } else
        capturedFile = await ImagePicker().getImage(
            source: ImageSource.gallery,
            imageQuality: 50,
            maxHeight: 480,
            maxWidth: 640);

      if (capturedFile != null) {
        setState(() {
          _imageStatus = imageStatusEnum.NewImageCaptured;
          _capturedFile = capturedFile;
        });
      }
    } on Exception catch (e) {
      showSnackBarMessage(e.toString(), reportFormScaffoldKey);
    }
  }

  _cancelCapturedImage() {
    setState(() {
      _imageStatus = imageStatusEnum.NoImage;
      _capturedFile = null;
    });
  }

  void _selectImage() async {
    try {
      final user = Provider.of<UserProfile>(context, listen: false);

      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
                height: 150,
                child: Column(children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text("Camera photo"),
                    onTap: () {
                      _toggleCameraGallerySelection(
                          ImageCapturingMethodEnum.Camera, user.organizationId);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text("Photo gallery"),
                    onTap: () {
                      _toggleCameraGallerySelection(
                          ImageCapturingMethodEnum.PhotoLibrary,
                          user.organizationId);
                      Navigator.pop(context);
                    },
                  )
                ]));
          });
    } on Exception catch (e) {
      showSnackBarMessage(e.toString(), reportFormScaffoldKey);
    }
  }

  _unFocus() {
    try {
      //unfocus address text to hide keyboard
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    } on Exception catch (e) {
      showSnackBarMessage(e.toString(), reportFormScaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      key: reportFormScaffoldKey,
      appBar: AppBar(
        title: Text('Report Information'),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                        child: Text(DateFormat('yyyy-MM-dd – kk:mm')
                            .format(_reportTimeStamp.toDate()))),
                    IconButton(
                        icon: Icon(Icons.alarm),
                        onPressed: () async {
                          _unFocus();
                          DateTime dt = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2010, 1, 1),
                              lastDate: DateTime(2030, 12, 31));

                          if (dt != null) {
                            TimeOfDay tm = await showTimePicker(
                                context: context, initialTime: TimeOfDay.now());
                            if (tm != null) {
                              setState(() => _reportTimeStamp =
                                  Timestamp.fromDate(DateTime(dt.year, dt.month,
                                      dt.day, tm.hour, tm.minute)));
                            }
                          }
                        })
                  ]),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _reportAddressController,
                decoration: InputDecoration(
                  labelText: 'ِAddress',
                  hintText: 'Enter address information',
                  hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                validator: (val) => (val != null && val.isEmpty)
                    ? 'Enter address information'
                    : null,
                onChanged: (val) => setState(() => _reportAddress = val),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField(
                  hint: Text(
                      'Specify material type'), // Not necessary for Option 1
                  value: _reportMaterial,
                  onTap: _unFocus,
                  validator: (val) =>
                      (val == null) ? 'Enter material type' : null,
                  onChanged: (value) {
                    setState(() {
                      _reportMaterial = value;
                    });
                  },
                  items: Globals.materialList.map((material) {
                    return DropdownMenuItem(
                      child: new Text(material),
                      value: material,
                    );
                  }).toList()),
              SizedBox(height: 10.0),
              DropdownButtonFormField(
                  hint: Text('Specify diameter'), // Not necessary for Option 1
                  value: _reportDiameter,
                  onTap: _unFocus,
                  validator: (val) => (val == null) ? 'Enter diameter' : null,
                  onChanged: (value) {
                    setState(() {
                      _reportDiameter = value;
                    });
                  },
                  items: Globals.diameterList.map((diameter) {
                    return DropdownMenuItem(
                      child: new Text(diameter.toString()),
                      value: diameter,
                    );
                  }).toList()),
              SizedBox(height: 10.0),
              DropdownButtonFormField(
                  hint: Text('Specify cause'), // Not necessary for Option 1
                  value: _reportCause,
                  onTap: _unFocus,
                  validator: (val) => (val == null) ? 'Enter cause' : null,
                  onChanged: (value) {
                    setState(() {
                      _reportCause = value;
                    });
                  },
                  items: Globals.causeList.map((cause) {
                    return DropdownMenuItem(
                      child: new Text(cause.toString()),
                      value: cause,
                    );
                  }).toList()),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                      child: Text(_reportLocationGpsString ??
                          'Select location from map')),
                  IconButton(
                      icon: Icon(Icons.gps_fixed),
                      onPressed: () {
                        _unFocus();
                        _selectLocationFromMap(context);
                      }),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_imageStatus == imageStatusEnum.NoImage
                      ? 'Capture an image for the site'
                      : 'Image selected'),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    _imageStatus != imageStatusEnum.NoImage
                        ? IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: _cancelCapturedImage)
                        : Container(),
                    _imageStatus != imageStatusEnum.NoImage
                        ? IconButton(
                            icon: Icon(Icons.image),
                            onPressed: _capturedFile != null
                                ? () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DisplayImage(
                                            file: File(_capturedFile.path))))
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DisplayImage(
                                            url: _reportImageURL))))
                        : Container(),
                    IconButton(
                        icon: Icon(Icons.camera),
                        onPressed: () {
                          _unFocus();
                          _selectImage();
                        }),
                  ])
                ],
              ),
              SizedBox(height: 10.0),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                RaisedButton(
                    color: Colors.blue[400],
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      _saveReport(_formKey);
                    }),
                RaisedButton(
                    color: Colors.blue[400],
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
