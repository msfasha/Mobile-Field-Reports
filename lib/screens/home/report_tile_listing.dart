import 'dart:io';

import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/display_image.dart';
import 'package:ufr/screens/home/report_display.dart';
import 'package:ufr/screens/home/report_entry.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';

typedef Widget ListingItemCreator(String s1, String s2, String s3);

class ReportTileListing extends StatefulWidget {
  ReportTileListing();

  @override
  _ReportTileListingState createState() => _ReportTileListingState();
}

class _ReportTileListingState extends State<ReportTileListing> {
  _ReportTileListingState();
  bool _loadingEffect;

  //Widget _mainDisplayWidget;
  //ListingItemCreator _lic;

  Widget _tileWidget(Report report) {
    final user = Provider.of<UserProfile>(context);

    bool canEdit = (user.userId == report.userId) ? true : false;
    return Card(
      margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
      child: ListTile(
        leading: report.imageURL != null
            ? IconButton(
                icon: Icon(Icons.photo_library),
                onPressed: () async {
                  try {
                    setState(() => _loadingEffect = true);
                    File file = await downloadFile(report.imageURL);
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisplayImage(file)));
                    setState(() => _loadingEffect = false);
                  } catch (e) {
                    showSnackBarMessage(
                        'error occured: ' + e.toString(), homeScaffoldKey);
                  }
                },
              )
            : null,
        title: Text(
            DateFormat('yyyy-MM-dd – kk:mm').format(report.time.toDate()) ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            )),
        subtitle: Text(report.address,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            canEdit == true
                ? IconButton(
                    icon: Icon(Icons.edit),
                    tooltip: 'Edit report information',
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ReportEntry(report: report))).catchError((e) {
                        showSnackBarMessage(
                            'Error Occured: ${e.toString()}', homeScaffoldKey);
                      });
                    })
                : IconButton(
                    icon: Icon(Icons.description),
                    tooltip: 'View report',
                    onPressed: () async {
                      OperationResult or;
                      setState(() => _loadingEffect = true);

                      or = await DataService.getPersonNameByUserId(
                          report.userId);
                      String personName;

                      if (or.operationCode == OperationResultCodeEnum.Success)
                        personName = or.content;
                      else if (or.operationCode ==
                          OperationResultCodeEnum.Error)
                        personName = or.content;

                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportDisplay(
                                    report: report,
                                    personName: personName,
                                  ))).catchError((e) {
                        setState(() => _loadingEffect = false);
                        showSnackBarMessage(
                            'Could not display report', homeScaffoldKey);
                      });
                      setState(() => _loadingEffect = false);
                    })
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<List<Report>>(context);

    if (reports == null) return Text('');

    return _loadingEffect == true
        ? Loading()
        : ListView.builder(
            itemCount: reports.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _tileWidget(reports[index]);
            },
          );
  }
}
