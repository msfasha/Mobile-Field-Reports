import 'dart:io';

import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/display_image.dart';
import 'package:ufr/screens/home/report_display.dart';
import 'package:ufr/screens/home/report_crud.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';

import '../../shared/aws_data_service.dart';

typedef ListingItemCreator = Widget Function(String s1, String s2, String s3);

class ReportTileListing extends StatefulWidget {
  const ReportTileListing({super.key});

  @override
  State<ReportTileListing> createState() => _ReportTileListingState();
}

class _ReportTileListingState extends State<ReportTileListing> {
  bool _loadingEffect = false;

  Widget _tileWidget(ReportCls report) {
    final user = Provider.of<UserProfile>(context);

    bool canEdit = (user.userId == report.userId) ? true : false;
    return Card(
      margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
      child: ListTile(
        leading: report.imageURL != null
            ? IconButton(
                icon: const Icon(Icons.photo_library),
                onPressed: () async {
                  try {
                    setState(() => _loadingEffect = true);
                    File file = await downloadFile(report.imageURL!);

                    if (context.mounted) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DisplayImage(file)));
                    }
                    setState(() => _loadingEffect = false);
                  } catch (e) {
                    if (context.mounted) {
                      showSnackBarMessage(context, 'error occurred: $e');
                      Navigator.pop(context);
                    }
                  }
                },
              )
            : null,
        title:
            Text(DateFormat('yyyy-MM-dd – kk:mm').format(report.time.toDate()),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                )),
        subtitle: Text(report.address!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            canEdit == true
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit report information',
                    onPressed: () {
                      Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ReportCrudScreen(report: report)))
                          .catchError((e) {
                        if (context.mounted) {
                          showSnackBarMessage(context, 'error occurred: $e');
                          Navigator.pop(context);
                        }
                      });
                    })
                : IconButton(
                    icon: const Icon(Icons.description),
                    tooltip: 'View report',
                    onPressed: () async {
                      try {
                        setState(() => _loadingEffect = true);

                        String personName =
                            await DataService.getPersonNameByUserId(
                                report.userId);
                        if (context.mounted) {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReportDisplay(
                                        report: report,
                                        personName: personName,
                                      )));
                          setState(() => _loadingEffect = false);
                        }
                      } catch (e) {
                        if (context.mounted) {
                          showSnackBarMessage(
                              context, 'Could not display report');
                          setState(() => _loadingEffect = false);
                        }
                      }
                    })
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<List<ReportCls>>(context);

    // if (reports == null) return const Text('');

    return _loadingEffect == true
        ? const Loading()
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
