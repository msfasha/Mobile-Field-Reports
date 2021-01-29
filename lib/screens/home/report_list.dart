import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReportList extends StatefulWidget {
  ReportList();

  @override
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {
  _ReportListState();

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<List<Report>>(context);

    if (reports == null) return Text('');
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        return ReportTile(
          timeTxt: DateFormat('yyyy-MM-dd – kk:mm')
                  .format(reports[index].time.toDate()) ??
              '',
          locationTxt: reports[index].address ?? '',
          reportId: reports[index].rid,
        );
      },
    );
  }
}
