import 'dart:convert';
import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/shared/modules.dart';

class ExportFromFireStore {
  static exportToCSV(String agencyId, BuildContext context) async {
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

      final reports = Provider.of<List<Report>>(context, listen: false);

      String row = 'agency_id' +
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

      reports.forEach((report) async {
        row = row + report.agencyId ??
            ''
                    ',' +
                (report.time != null ? report.time.toDate().toString() : '') +
                ',' +
                report.address ??
            ''
                    ',' +
                (report.locationGeoPoint != null
                    ? report.locationGeoPoint.latitude.toString() +
                        '-' +
                        report.locationGeoPoint.longitude.toString()
                    : '') +
                ',' +
                (report.diameter != null ? report.diameter.toString() : '') +
                ',' +
                report.material ??
            '' + ',' + report.cause ??
            '' + '\n';

        //sink.writeln(row);
      });
      //await file.writeAsBytes(utf8.encode(row), flush: true);
      await file.writeAsString(row, encoding: utf8, flush: true);
      //sink.flush();
      //sink.close();

      showSnackBarMessage('File saved in $downloadDir', homeScaffoldKey);
    } catch (e) {
      showSnackBarMessage('error occured: ' + e.toString(), homeScaffoldKey);
    }
  }
}
