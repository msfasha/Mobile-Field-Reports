import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufr/services/database.dart';

class ReportsAsRows extends StatelessWidget {
  ReportsAsRows() {
    print('As Rows');
  }

  Widget _getRow(String timeTxt, String locationTxt, String reportId,
      BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
            flex: 6,
            child: Text(timeTxt,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                )),
          ),
          Expanded(
            flex: 4,
            child: Text(locationTxt,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                )),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'Edit report information',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReportForm(reportId: reportId)));
                //showReportPanel(context: context, reportId: reportId);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.delete),
              tooltip: 'Delete report',
              onPressed: () {
                DatabaseService().deleteReport(reportId);
              },
            ),
          ),
        ]),
        Divider(thickness: 1, color: Colors.black),
      ],
    );
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    final reports = Provider.of<List<Report>>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
      child: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          return _getRow(
              DateFormat('yyyy-MM-dd – kk:mm')
                      .format(reports[index].time.toDate()) ??
                  '',
              reports[index].address ?? '',
              reports[index].rid,
              context);
        },
      ),
    );
  }
}
