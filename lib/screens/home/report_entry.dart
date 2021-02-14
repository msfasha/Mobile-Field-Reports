import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:provider/provider.dart';

import 'package:ufr/models/report.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/map_report_point.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';
import 'display_image.dart';

enum imageStatusEnum {
  NoImage,
  NewImageCaptured,
  ExistingImage,
}

class ReportEntry extends StatefulWidget {
  final Report report;

  ReportEntry({this.report});

  @override
  _ReportEntryState createState() => _ReportEntryState(report);
}

class _ReportEntryState extends State<ReportEntry> {
  bool _loadingEffect = false;
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

  _ReportEntryState(this._report);

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

  Future<OperationResult> _saveReport(GlobalKey<FormState> _key) async {
    OperationResult or = OperationResult();

    if (!_key.currentState.validate()) return or;

    String storagePath;
    if (_capturedFile != null) {
      or = await _uploadImage();
      if (or.operationCode == OperationResultCodeEnum.Success)
        storagePath = or.content;
      else if (or.operationCode == OperationResultCodeEnum.Error) {
        showSnackBarMessage(or.message, reportFormScaffoldKey);
        return or;
      }
    }

    final user = Provider.of<UserProfile>(context, listen: false);
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
      or = await DataService.createReport(report);
    } else {
      report.rid = _report.rid;
      or = await DataService.updateReport(report);
    }

    return or;
  }

  void _selectLocationFromMap(BuildContext context) async {
    try {
      final GeoPoint result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapReportPoint(
                selectedGeoPoint: _reportLocationGeoPoint,
                useMode: MapReportPointUseModeEnum.AllowSelect)),
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

  Future<OperationResult> _uploadImage() async {
    OperationResult or = OperationResult();
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('ufr/')
          .child('${_capturedFile.path.split('/').last}');

      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': _capturedFile.path});

      await ref.putFile(File(_capturedFile.path), metadata);

      or.operationCode = OperationResultCodeEnum.Success;
      or.content = ref.fullPath;
      return or;
    } on Exception catch (e) {
      or.operationCode = OperationResultCodeEnum.Error;
      or.message = e.toString();
      return or;
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
      body: _loadingEffect == true
          ? Loading()
          : Form(
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
                                      context: context,
                                      initialTime: TimeOfDay.now());
                                  if (tm != null) {
                                    setState(() => _reportTimeStamp =
                                        Timestamp.fromDate(DateTime(
                                            dt.year,
                                            dt.month,
                                            dt.day,
                                            tm.hour,
                                            tm.minute)));
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
                        hintStyle:
                            TextStyle(fontSize: 12.0, color: Colors.grey),
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
                        hint: Text(
                            'Specify diameter'), // Not necessary for Option 1
                        value: _reportDiameter,
                        onTap: _unFocus,
                        validator: (val) =>
                            (val == null) ? 'Enter diameter' : null,
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
                        hint:
                            Text('Specify cause'), // Not necessary for Option 1
                        value: _reportCause,
                        onTap: _unFocus,
                        validator: (val) =>
                            (val == null) ? 'Enter cause' : null,
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
                                  //if there is an image, display cancel image selection
                                  icon: Icon(Icons.cancel),
                                  onPressed: _cancelCapturedImage)
                              : Container(),
                          _imageStatus != imageStatusEnum.NoImage
                              ? IconButton(
                                  //if there is an image, display delete image selection
                                  icon: Icon(Icons.image),
                                  onPressed: () async {
                                    try {
                                      if (_capturedFile != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DisplayImage(File(
                                                        _capturedFile.path))));
                                      } else {
                                        setState(() => _loadingEffect = true);
                                        File file =
                                            await downloadFile(_reportImageURL);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DisplayImage(file)));
                                        setState(() => _loadingEffect = false);
                                      }
                                    } on Exception {
                                      setState(() => _loadingEffect = false);
                                      showSnackBarMessage(
                                          'Can not display the image',
                                          homeScaffoldKey);
                                    }
                                  })
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
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RaisedButton(
                              color: Colors.blue[400],
                              child: Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                OperationResult or;

                                setState(() => _loadingEffect = true);
                                or = await _saveReport(_formKey);

                                if (or.operationCode ==
                                    OperationResultCodeEnum.Success) {
                                  showSnackBarMessage(
                                      'Report successfully saved',
                                      reportFormScaffoldKey);
                                  Navigator.pop(context);
                                } else if (or.operationCode ==
                                    OperationResultCodeEnum.Error) {
                                  setState(() => _loadingEffect = false);
                                  showSnackBarMessage(
                                      'Error Occured: ${or.message}',
                                      reportFormScaffoldKey);
                                }
                              }),
                          RaisedButton(
                              color: Colors.blue[400],
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                setState(() => _loadingEffect = true);
                                await DataService.deleteReport(_report.rid);
                                Navigator.pop(context);
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
