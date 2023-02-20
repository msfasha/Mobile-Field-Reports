import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/shared/modules.dart';

class ExportFromFireStore {
  static Future<void> exportToCSV(String agencyId, BuildContext context) async {
    try {
      var status = await Permission.storage.status;

      if (status != PermissionStatus.granted) {
        status = await Permission.storage.request();

        if (status != PermissionStatus.granted) {
          if (context.mounted) {
            showSnackBarMessage(context, 'No permission to write to disk');
          }
          return;
        }
      }

      // String downloadDir = await ExtStorage.getExternalStoragePublicDirectory(
      //     ExtStorage.DIRECTORY_DOWNLOADS);
      String downloadDir = "must be defined";
      // String fileFullPath =
      //     '$downloadDir/${DateFormat('yyyy_MM_dd_kk_mm_ss').format(DateTime.now())}.csv';

      String fileFullPath =
          '${DateFormat('yyyy_MM_dd_kk_mm_ss').format(DateTime.now())}.csv';

      File file = File(fileFullPath);

      dynamic reports;
      if (context.mounted) {
        reports = Provider.of<List<ReportCls>>(context, listen: false);
      }

      String? row =
          'agency_id,time,address,location_geopoint,diameter,material,cause\n';

      var buffer = StringBuffer();
      buffer.write(row);

      for (var report in reports) {
        row = (report.agencyId);
        row = '$row,';
        row = row + (report.time.toDate().toString());
        row = '$row,';
        row = row + (report.address);
        row = '$row,';
        row = row +
            (report.locationGeoPoint != null
                ? '${report.locationGeoPoint!.latitude}-${report.locationGeoPoint!.longitude}'
                : '');
        row = '$row,';
        row = row + (report.diameter.toString());
        row = '$row,';
        row = row + report.material;
        row = '$row,';
        row = row + report.cause;
        row = '$row\n';
        buffer.write(row);
        row = null;
      }

      await file.writeAsString(buffer.toString(), encoding: utf8, flush: true);

      if (context.mounted) {
        showSnackBarMessage(context, 'File saved in $downloadDir');
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBarMessage(context, 'error occurred: $e');
        Navigator.pop(context);
      }
    }
  }
}
