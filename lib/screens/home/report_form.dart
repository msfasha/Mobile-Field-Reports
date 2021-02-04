import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/models/user.dart';
import 'package:ufr/screens/home/custom_map.dart';
import 'package:provider/provider.dart';
import 'package:ufr/services/firebase.dart';
import 'package:ufr/shared/constants.dart';
import 'package:ufr/shared/modules.dart';

class ReportForm extends StatefulWidget {
  final Report report;

  ReportForm({this.report});

  @override
  _ReportFormState createState() => _ReportFormState(report);
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final Report _report;
  CrudOperationTypeEnum _crudOperationType;

  Timestamp _reportTimeStamp = Timestamp.fromDate(DateTime.now());

  String _reportAddress;
  TextEditingController _reportAddressController = new TextEditingController();
  String _reportLocationGpsString;
  GeoPoint _reportLocationGeoPoint;
  String _reportMaterial;
  int _reportDiameter;
  String _reportCause;
  //PickedFile _pickedFile;

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
      if (Constants.materialList.contains(report.material))
        _reportMaterial = report.material;

      if (Constants.diameterList.contains(report.diameter))
        _reportDiameter = report.diameter;

      if (Constants.causeList.contains(report.cause))
        _reportCause = report.cause;
    });
  }

  _saveReport(GlobalKey<FormState> _key) async {
    if (_key.currentState.validate()) {
      final user = Provider.of<User>(context, listen: false);

      Report report = Report(
          userId: user.userId,
          utilityId: user.utilityId,
          time: _reportTimeStamp,
          address: _reportAddress,
          locationGeoPoint: _reportLocationGeoPoint,
          material: _reportMaterial,
          diameter: _reportDiameter,
          cause: _reportCause);

      if (_crudOperationType == CrudOperationTypeEnum.Create) {
        DatabaseService.createReport(report).then((value) {
          showSnackBarMessage('Report successfully saved');
          Navigator.pop(context);
        }).catchError((e) {
          showSnackBarMessage('Error Occured: ${e.toString()}');
        });
      } else {
        report.rid = _report.rid;
        DatabaseService.updateReport(report).then((value) {
          showSnackBarMessage('Report successfully saved');
          Navigator.pop(context);
        }).catchError((e) {
          showSnackBarMessage('Error Occured: ${e.toString()}');
        });
      }
    }
  }

  void _selectLocationFromMap(BuildContext context) async {
    final GeoPoint result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CustomMap(selectedGeoPoint: _reportLocationGeoPoint)),
    );
    if (result != null) {
      setState(() {
        _reportLocationGeoPoint = result;
        _reportLocationGpsString =
            result.latitude.toString() + " , " + result.longitude.toString();
      });
    }
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              height: 150,
              child: Column(children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text("Take a picture from camera"),
                  onTap: () async {
                    final file = await ImagePicker()
                        .getImage(source: ImageSource.camera);
                    print(file.path);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text("Choose from photo library"),
                  onTap: () async {
                    final file = await ImagePicker()
                        .getImage(source: ImageSource.gallery);
                    print(file.path);
                  },
                ),
              ]));
        });
  }

  _unFocus() {
    //unfocus address text to hide keyboard
    FocusScopeNode currentFocus = FocusScope.of(context);
    print(currentFocus);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return Builder(
        builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Report Information'),
                backgroundColor: Colors.blue[400],
                elevation: 0.0,
              ),
              body: Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.white,
                  //height: MediaQuery.of(context).size.height * .9,
                  //width: MediaQuery.of(context).size.width * .2,
                  child: ListView(
                    children: <Widget>[
                      Row(children: <Widget>[
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
                        onChanged: (val) =>
                            setState(() => _reportAddress = val),
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
                          items: Constants.materialList.map((material) {
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
                          items: Constants.diameterList.map((diameter) {
                            return DropdownMenuItem(
                              child: new Text(diameter.toString()),
                              value: diameter,
                            );
                          }).toList()),
                      SizedBox(height: 10.0),
                      DropdownButtonFormField(
                          hint: Text(
                              'Specify cause'), // Not necessary for Option 1
                          value: _reportCause,
                          onTap: _unFocus,
                          validator: (val) =>
                              (val == null) ? 'Enter cause' : null,
                          onChanged: (value) {
                            setState(() {
                              _reportCause = value;
                            });
                          },
                          items: Constants.causeList.map((cause) {
                            return DropdownMenuItem(
                              child: new Text(cause.toString()),
                              value: cause,
                            );
                          }).toList()),
                      SizedBox(height: 10.0),
                      Row(
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
                        children: <Widget>[
                          Flexible(
                              child: Text(
                                  _reportLocationGpsString ?? 'Take a photo')),
                          IconButton(
                              icon: Icon(Icons.camera),
                              onPressed: () {
                                _unFocus();
                                _showPhotoOptions(context);
                              }),
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }
}
