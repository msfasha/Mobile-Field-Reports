import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/models/user.dart';
import 'package:ufr/screens/home/custom_map.dart';
import 'package:ufr/services/database.dart';
import 'package:provider/provider.dart';

class ReportForm extends StatefulWidget {
  final String reportId;

  ReportForm({this.reportId});

  @override
  _ReportFormState createState() => _ReportFormState(reportId);
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final String _reportId;

  Timestamp _reportTimeStamp = Timestamp.fromDate(DateTime.now());

  String _reportAddress;
  TextEditingController _reportAddressController = new TextEditingController();
  String _reportLocationGpsString;
  GeoPoint _reportLocationGeoPoint;
  String _reportMaterial;
  int _reportDiameter;
  String _reportCause;

  static const List<int> _diameterList = [
    50,
    63,
    75,
    80,
    100,
    110,
    125,
    150,
    180,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
    550,
    600,
    650,
    700,
    750,
    800,
    850,
    900,
    950,
    1000,
    1050,
    1100,
    1150,
    1200,
    1250,
    1300,
    1350,
    1400,
    1450,
    1500,
    1550,
    1600,
    1650,
    1700,
    1750,
    1800,
    1850,
    1900,
    1950,
    2000,
    2050,
    2100,
    2150,
    2200,
    2250,
    2300,
    2350
  ];
  static const List<String> _materialList = ['GI', 'ST', 'DI', 'PVC', 'HDPE'];
  static const List<String> _causeList = [
    'High Pressure',
    'Negative Pressure',
    'Hit by Mistake',
    'Old Pipe',
    'Bad Installation'
  ];

  _ReportFormState(this._reportId);

  @override
  void initState() {

    if (_reportId != null) _getExistingRecord();
    super.initState();

  }

  @override
  void dispose() {
    _reportAddressController?.dispose();

    super.dispose();
  }

  void _getExistingRecord() {
    try {
      DatabaseService().getReport(_reportId).then((value) {
        setState(() {
          _reportTimeStamp = value.time;

          _reportAddressController.text = value.address;
          _reportAddress = value.address;

          _reportLocationGeoPoint = value.locationGeoPoint;
          _reportLocationGpsString = _reportLocationGeoPoint != null
              ? value.locationGeoPoint.latitude.toString() +
                  " , " +
                  value.locationGeoPoint.longitude.toString()
              : '';
          if (_materialList.contains(value.material))
          _reportMaterial = value.material;

          if (_diameterList.contains(value.diameter))
          _reportDiameter = value.diameter;

          if (_causeList.contains(value.cause))
          _reportCause = value.cause;
        });
      });
   } on Exception catch (e, st) {
      AlertDialog(
          title: Text("Error"), content: Text(e.toString() + st.toString()));
      //return createErrorWidget(e, st);
    }
  }

  _saveReport(BuildContext context, GlobalKey<FormState> _key) async {
    try {
      if (_key.currentState.validate()) {
        final user = Provider.of<User>(context, listen: false);

        Report report = Report(
            rid: _reportId,
            userId: user.userId,
            utilityId: user.utilityId,
            time: _reportTimeStamp,
            address: _reportAddress,
            locationGeoPoint: _reportLocationGeoPoint,
            material: _reportMaterial,
            diameter: _reportDiameter,
            cause: _reportCause);

        if (_reportId == null)
          await DatabaseService().createReport(report);
        else
          await DatabaseService().updateReport(report);

        Navigator.pop(context);
      }
    } on Exception catch (e, st) {
      AlertDialog(
          title: Text("Error"), content: Text(e.toString() + st.toString()));
      //return createErrorWidget(e, st);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      DateTime dt = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2010, 1, 1),
                          lastDate: DateTime(2030, 12, 31));

                      if (dt != null) {
                        TimeOfDay tm = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        if (tm != null) {
                          setState(() => _reportTimeStamp = Timestamp.fromDate(
                              DateTime(dt.year, dt.month, dt.day, tm.hour,
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
                  hintStyle: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
                validator: (val) => (val != null && val.isEmpty)
                    ? 'Enter address information'
                    : null,
                onChanged: (val) => setState(() => _reportAddress = val),
              ),
              SizedBox(height: 10.0),
              Row(
                children: <Widget>[
                  Flexible(
                      child: Text(_reportLocationGpsString ??
                          'Select location from map')),
                  IconButton(
                      icon: Icon(Icons.gps_fixed),
                      onPressed: () {
                        _selectLocationFromMap(context);
                      }),
                ],
              ),
              SizedBox(height: 10.0),
              DropdownButton(
                  hint: Text(
                      'Specify material type'), // Not necessary for Option 1
                  value: _reportMaterial,
                  onChanged: (value) {
                    setState(() {
                      _reportMaterial = value;
                    });
                  },
                  items: _materialList.map((material) {
                    return DropdownMenuItem(
                      child: new Text(material),
                      value: material,
                    );
                  }).toList()),
              SizedBox(height: 10.0),
              DropdownButton(
                  hint: Text('Specify diameter'), // Not necessary for Option 1
                  value: _reportDiameter,
                  onChanged: (value) {
                    setState(() {
                      _reportDiameter = value;
                    });
                  },
                  items: _diameterList.map((diameter) {
                    return DropdownMenuItem(
                      child: new Text(diameter.toString()),
                      value: diameter,
                    );
                  }).toList()),
              SizedBox(height: 10.0),
              DropdownButton(
                  hint: Text('Specify cause'), // Not necessary for Option 1
                  value: _reportCause,
                  onChanged: (value) {
                    setState(() {
                      _reportCause = value;
                    });
                  },
                  items: _causeList.map((cause) {
                    return DropdownMenuItem(
                      child: new Text(cause.toString()),
                      value: cause,
                    );
                  }).toList()),
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
                      onPressed: () => _saveReport(context, _formKey)),
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
    );
  }
}

//height: MediaQuery.of(context).size.height * 0.2,
