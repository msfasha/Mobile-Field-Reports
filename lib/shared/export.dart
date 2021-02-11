import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/modules.dart';

class ExportFromFireStore {
  static exportToCSV(String organizationId, BuildContext context) async {
    try {
      var status = await Permission.storage.status;

      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();

        if (status != PermissionStatus.granted) {
          showSnackBarMessage(
              'No permission to write to disk', homeScaffoldKey);
          return;
        }
      }

      String downloadDir = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      String fileFullPath = downloadDir +
          '/' +
          DateFormat('yyyy_MM_dd_kk_mm_ss').format(DateTime.now()) +
          '.csv';

      File file = new File(fileFullPath);
      //IOSink sink = file.openWrite(encoding: Encoding.getByName('utf8'));
      //IOSink sink = file.openWrite(encoding: Encoding.getByName('utf8'));
      //IOSink sink = file.openWrite(encoding: Encoding.getByName('utf8'));

      QuerySnapshot querySnapshot =
          await DataService.getReportsSnapshot(organizationId);

      String row = 'organization_id' +
          ',' +
          'time' +
          ',' +
          'address' +
          ',' +
          'location_geopoint' +
          ',' +
          'diameter' +
          ',' +
          'material' +
          ',' +
          'cause' +
          '\n';

      //sink.writeln(row);

      querySnapshot.docs.forEach((element) async {
        row = row +
            (element.data()['organization_id'] != null
                ? element.data()['organization_id'].toString()
                : '') +
            ',' +
            (element.data()['time'] != null
                ? (element.data()['time'] as Timestamp).toDate().toString()
                : '') +
            ',' +
            (element.data()['address'] != null
                ? element.data()['address']
                : '') +
            ',' +
            (element.data()['location_geopoint'] != null
                ? (element.data()['location_geopoint'] as GeoPoint)
                        .latitude
                        .toString() +
                    '-' +
                    (element.data()['location_geopoint'] as GeoPoint)
                        .longitude
                        .toString()
                : '') +
            ',' +
            (element.data()['diameter'] != null
                ? element.data()['diameter'].toString()
                : '') +
            ',' +
            (element.data()['material'] != null
                ? element.data()['material']
                : '') +
            ',' +
            (element.data()['cause'] != null ? element.data()['cause'] : '') +
            '\n';

        //sink.writeln(row);
      });
      //await file.writeAsBytes(utf8.encode(row), flush: true);
      await file.writeAsString(row, encoding: utf8, flush: true);
      //sink.flush();
      //sink.close();

      showSnackBarMessage('File saved in $downloadDir', homeScaffoldKey);
    } on Exception catch (e) {
      showSnackBarMessage('Error occured: ${e.toString()}', homeScaffoldKey);
    }
  }
}
