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

      var buffer = new StringBuffer();
      buffer.write(row);

      reports.forEach((report) {
        row = (report.agencyId ?? '');
        row = row + ',';
        row =
            row + (report.time != null ? report.time.toDate().toString() : '');
        row = row + ',';
        row = row + report.address ?? '';
        row = row + ',';
        row = row +
            (report.locationGeoPoint != null
                ? report.locationGeoPoint.latitude.toString() +
                    '-' +
                    report.locationGeoPoint.longitude.toString()
                : '');
        row = row + ',';
        row = row + (report.diameter != null ? report.diameter.toString() : '');
        row = row + ',';
        row = row + report.material ?? '';
        row = row + ',';
        row = row + report.cause ?? '';
        row = row + '\n';
        buffer.write(row);
        row = null;
      });

      //TODO check unicode issue
      await file.writeAsString(buffer.toString(), encoding: utf8, flush: true);

      showSnackBarMessage('File saved in $downloadDir', homeScaffoldKey);
    } catch (e) {
      showSnackBarMessage('error occured: ' + e.toString(), homeScaffoldKey);
    }
  }
}
