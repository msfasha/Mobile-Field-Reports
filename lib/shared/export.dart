import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ufr/services/database.dart';

class ExportFromFireStore {
  static Future<String> exportToCSV() async {
    try {
      var status = await Permission.storage.status;

      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();
        if (status != PermissionStatus.granted) {
          return "Write permission not granted";
        }
      }

      String downloadDir = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_DOWNLOADS);
      String fileFullPath = downloadDir +
          '/' +
          DateFormat('yyyy_MM_dd_kk_mm_ss').format(DateTime.now()) +
          '.csv';

      var file = new File(fileFullPath);
      var sink = file.openWrite();

      QuerySnapshot querySnapshot =
          await DatabaseService().reportsCollection.get();

      var row = 'id' +
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
          row = element.id +
              ',' +
              element.data()['user_id'].toString() +
              ',' +
              element.data()['utility_id'].toString() +
              ',' +
              (element.data()['time'] as Timestamp).toDate().toString() +
              ',' +
              element.data()['address'] +
              ',' +
              (element.data()['location_geopoint'] as GeoPoint)
                  .latitude
                  .toString() +
              '-' +
              (element.data()['location_geopoint'] as GeoPoint)
                  .longitude
                  .toString() +
              ',' +              
              element.data()['diameter'].toString() +
              ',' +
              element.data()['material'] +
              ',' +
              element.data()['cause'] +
              '\n';

          sink.write(row);
        });
      }
      //sink.flush();
      sink.close();

      return "File saved in $downloadDir";
    } on Exception catch (e) {
      throw e;
    }
  }
}
