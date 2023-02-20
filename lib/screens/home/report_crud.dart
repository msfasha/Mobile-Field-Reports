import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:ufr/models/report.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/select_map_point.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';
import 'package:ufr/screens/home/display_image.dart';

import '../../shared/aws_data_service.dart';

enum ImageStatusEnum {
  noImage,
  newImageCaptured,
  imageExists,
}

class ReportCrudScreen extends StatefulWidget {
  final ReportCls? report;

  const ReportCrudScreen({super.key, required this.report});

  @override
  State<ReportCrudScreen> createState() => _ReportCrudScreenState();
}

class _ReportCrudScreenState extends State<ReportCrudScreen> {
  //the report variable will be initialized in the initialState
  //If a reportCls is passed, this value will be used for initiliazing the report variable
  //Otherwise, a new reportCls will be created
  late ReportCls report;

  bool _loadingEffect = false;
  final _formKey = GlobalKey<FormState>();
  ImageStatusEnum _imageStatus = ImageStatusEnum.noImage;
  late CrudOperationTypeEnum _crudOperationType;

  String? _reportLocationGpsString;
  PickedFile? _diskFile;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      //display existing report
      report = widget.report!;

      //the value below will be passed to a Text Widget during the initial loading process
      _reportLocationGpsString = report.locationGeoPoint != null
          ? "${report.locationGeoPoint!.latitude} , ${report.locationGeoPoint!.longitude}"
          : 'Select location from map';

      _imageStatus = report.imageURL != null
          ? ImageStatusEnum.imageExists
          : ImageStatusEnum.noImage;

      _crudOperationType = CrudOperationTypeEnum.update;
    } else {
      //initialize a new reportCls
      final user = Provider.of<UserProfile>(context, listen: false);
      report = ReportCls(
          userId: user.userId,
          agencyId: user.agencyId,
          time: Timestamp.fromDate(DateTime.now()));

      _crudOperationType = CrudOperationTypeEnum.create;
    }
  }

  //Save report method
  Future<void> _saveReport() async {
    try {
      if (_imageStatus == ImageStatusEnum.newImageCaptured) {
        report.imageURL = await _uploadImage();
      }

      if (_crudOperationType == CrudOperationTypeEnum.create) {
        await DataService.createReport(report);
      } else {
        await DataService.updateReport(report);
      }
    } catch (e) {
      rethrow;
    }
  }

  //Select location from map method
  void _selectLocationFromMap(BuildContext context) async {
    try {
      final GeoPoint gePoint = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SelectMapPoint(
                initialGeoPoint: report.locationGeoPoint,
                useMode: SelectMapPointUseModeEnum.allowSelect)),
      );

      report.locationGeoPoint = gePoint;
    } catch (e) {
      if (context.mounted) {
        showSnackBarMessage(context, 'error occurred: $e');
      }
    }
  }

  //Upload image method
  Future<String> _uploadImage() async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('ufr/')
          .child(_diskFile!.path.split('/').last);

      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': _diskFile!.path});

      await ref.putFile(File(_diskFile!.path), metadata);

      return ref.fullPath;
    } catch (e) {
      rethrow;
    }
  }

  //Toggle Camera vs Gallery Selection Method
  _showImagePicker(ImageCapturingMethodEnum imageCapturingMethod) async {
    try {
      XFile? diskFile;

      if (imageCapturingMethod == ImageCapturingMethodEnum.camera) {
        diskFile = await ImagePicker().pickImage(
            source: ImageSource.camera,
            imageQuality: 50,
            maxHeight: 480,
            maxWidth: 640);
      } else {
        diskFile = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: 50,
            maxHeight: 480,
            maxWidth: 640);
      }

      if (diskFile != null) {
        setState(() {
          _imageStatus = ImageStatusEnum.newImageCaptured;
          _diskFile = diskFile as PickedFile?;
        });
      }
    } on Exception catch (e) {
      if (context.mounted) {
        showSnackBarMessage(context, 'error occurred: $e');
      }
    }
  }

  //Cancel Captured Image Method
  _cancelCapturedImage() {
    _imageStatus = ImageStatusEnum.noImage;
    report.imageURL = null;
    _diskFile = null;
  }

  //Select Image Method
  void _startImageSelectionProcess() async {
    try {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return SizedBox(
                height: 150,
                child: Column(children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text("Camera photo"),
                    onTap: () {
                      _showImagePicker(ImageCapturingMethodEnum.camera);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text("Photo gallery"),
                    onTap: () {
                      _showImagePicker(ImageCapturingMethodEnum.photoLibrary);
                      Navigator.pop(context);
                    },
                  )
                ]));
          });
    } catch (e) {
      if (context.mounted) {
        showSnackBarMessage(context, 'error occurred: $e');
        Navigator.pop(context);
      }
    }
  }

  //Unfocus Method
  _unFocus() {
    try {
      //unfocus address text to hide keyboard
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBarMessage(context, 'error occurred: $e');
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Information'),
        elevation: 0.0,
      ),
      body: _loadingEffect == true
          ? const Loading()
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
                                  .format(report.time.toDate()))),
                          IconButton(
                              icon: const Icon(Icons.alarm),
                              onPressed: () async {
                                _unFocus();
                                DateTime? dt = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2010, 1, 1),
                                    lastDate: DateTime(2030, 12, 31));
                                TimeOfDay? tm;
                                if (context.mounted) {
                                  tm = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now());
                                }

                                report.time = Timestamp.fromDate(DateTime(
                                    dt!.year,
                                    dt.month,
                                    dt.day,
                                    tm!.hour,
                                    tm.minute));
                              })
                        ]),
                    const SizedBox(height: 10.0),
                    TextFormField(
                      initialValue: report.address,
                      // controller: _reportAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter address information',
                      ),
                      validator: (val) => (val != null && val.isEmpty)
                          ? 'Enter address information'
                          : null,
                      onChanged: (val) => report.address = val,
                    ),
                    const SizedBox(height: 10.0),
                    DropdownButtonFormField(
                        hint: const Text(
                            'Specify material type'), // Not necessary for Option 1
                        value: report.material,
                        onTap: _unFocus,
                        validator: (val) =>
                            (val == null) ? 'Enter material type' : null,
                        onChanged: (value) => report.material = value!,
                        items: Globals.materialList.map((material) {
                          return DropdownMenuItem(
                            value: material,
                            child: Text(material),
                          );
                        }).toList()),
                    const SizedBox(height: 10.0),
                    DropdownButtonFormField(
                        hint: const Text(
                            'Specify diameter'), // Not necessary for Option 1
                        value: report.diameter,
                        onTap: _unFocus,
                        validator: (val) =>
                            (val == null) ? 'Enter diameter' : null,
                        onChanged: (value) {
                          report.diameter = value!;
                        },
                        items: Globals.diameterList.map((diameter) {
                          return DropdownMenuItem(
                            value: diameter,
                            child: Text(diameter.toString()),
                          );
                        }).toList()),
                    const SizedBox(height: 10.0),
                    DropdownButtonFormField(
                        hint: const Text(
                            'Specify cause'), // Not necessary for Option 1
                        value: report.cause,
                        onTap: _unFocus,
                        validator: (val) =>
                            (val == null) ? 'Enter cause' : null,
                        onChanged: (value) {
                          report.cause = value!;
                        },
                        items: Globals.causeList.map((cause) {
                          return DropdownMenuItem(
                            value: cause,
                            child: Text(cause.toString()),
                          );
                        }).toList()),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                            child: Text(_reportLocationGpsString ??
                                'Select location from map')),
                        IconButton(
                            icon: const Icon(Icons.gps_fixed),
                            onPressed: () {
                              _unFocus();
                              _selectLocationFromMap(context);
                            }),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(_imageStatus == ImageStatusEnum.noImage
                            ? 'Capture an image for the site'
                            : 'Image selected'),
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          _imageStatus != ImageStatusEnum.noImage
                              ? IconButton(
                                  //if there is an image, display cancel image selection
                                  icon: const Icon(Icons.cancel),
                                  onPressed: _cancelCapturedImage)
                              : Container(),
                          _imageStatus != ImageStatusEnum.noImage
                              ? IconButton(
                                  //if there is an image, display delete image selection
                                  icon: const Icon(Icons.image),
                                  onPressed: () async {
                                    try {
                                      if (_diskFile != null) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DisplayImage(File(
                                                        _diskFile!.path))));
                                      } else {
                                        setState(() => _loadingEffect = true);
                                        File file = await downloadFile(
                                            report.imageURL!);
                                        setState(() => _loadingEffect = false);
                                        if (context.mounted) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DisplayImage(file)));
                                        }
                                      }
                                    } catch (e) {
                                      setState(() => _loadingEffect = false);

                                      if (context.mounted) {
                                        showSnackBarMessage(
                                            context, 'error occurred: $e');
                                        Navigator.pop(context);
                                      }
                                    }
                                  })
                              : Container(),
                          IconButton(
                              icon: const Icon(Icons.camera),
                              onPressed: () {
                                _unFocus();
                                _startImageSelectionProcess();
                              }),
                        ])
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              child: const Text(
                                'Save',
                              ),
                              onPressed: () async {
                                try {
                                  setState(() => _loadingEffect = true);
                                  if (_formKey.currentState!.validate()) {
                                    await _saveReport();

                                    if (context.mounted) {
                                      showSnackBarMessage(
                                          context, 'Report successfully saved');
                                    }
                                  }
                                  setState(() => _loadingEffect = false);
                                } catch (e) {
                                  setState(() => _loadingEffect = false);
                                  if (context.mounted) {
                                    showSnackBarMessage(
                                        context, 'Report successfully saved');
                                  }
                                }
                              }),
                          ElevatedButton(
                              child: const Text(
                                'Delete',
                              ),
                              onPressed: () async {
                                try {
                                  setState(() => _loadingEffect = true);
                                  await DataService.deleteReport(report.rid!);
                                  if (context.mounted) Navigator.pop(context);
                                } catch (e) {
                                  setState(() => _loadingEffect = false);
                                  if (context.mounted) {
                                    showSnackBarMessage(
                                        context, 'error occurred: $e');
                                    Navigator.pop(context);
                                  }
                                }
                              }),
                          ElevatedButton(
                              child: const Text(
                                'Cancel',
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
