import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ufr/services/firebase.dart';
import 'package:ufr/shared/modules.dart';

class ExportFromFireStore {
  static exportToCSV(int utilityId, BuildContext context) async {
    try {
      var status = await Permission.storage.status;

      print(status);

      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();

        status = await Permission.storage.request();

        if (status != PermissionStatus.granted) {
          showSnackBarMessage('No permission to write to disk');
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
      IOSink sink = file.openWrite();

      QuerySnapshot querySnapshot =
          await DatabaseService.getReportsSnapshot(utilityId);

      String row = 'id' +
          ',' +
          'uesr_id' +
          ',' +
          'utility_id' +
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
          'cause\n';

      sink.write(row);

      if (querySnapshot.size != 0) {
        querySnapshot.docs.forEach((element) {
          row = element.id + ',' + element.data()['user_id'] != null
              ? element.data()['user_id'].toString()
              : '' + ',' + element.data()['utility_id'] != null
                  ? element.data()['utility_id'].toString()
                  : '' + ',' + element.data()['time'] != null
                      ? (element.data()['time'] as Timestamp)
                          .toDate()
                          .toString()
                      : '' + ',' + element.data()['address'] != null
                          ? element.data()['address']
                          : '' + ',' + element.data()['location_geopoint'] !=
                                  null
                              ? (element.data()['location_geopoint']
                                          as GeoPoint)
                                      .latitude
                                      .toString() +
                                  '-' +
                                  (element.data()['location_geopoint']
                                          as GeoPoint)
                                      .longitude
                                      .toString()
                              : '' + ',' + element.data()['diameter'] != null
                                  ? element.data()['diameter'].toString()
                                  : '' + ',' + element.data()['material'] !=
                                          null
                                      ? element.data()['material']
                                      : '' + ',' + element.data()['cause'] !=
                                              null
                                          ? element.data()['cause']
                                          : '' + '\n';

          sink.write(row);
        });
      }
      //sink.flush();
      sink.close();

      showSnackBarMessage('File saved in $downloadDir');
    } on Exception catch (e) {
      showSnackBarMessage('Error occured: ${e.toString()}');
    }
  }
}
