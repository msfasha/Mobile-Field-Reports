import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufr/services/database.dart';

class ReportsAsTiles extends StatelessWidget { 
  ReportsAsTiles() {
    print('As Tiles');
  }

  Widget _getTile(String timeTxt, String locationTxt, String reportId, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          // leading: CircleAvatar(
          //   radius: 25.0,
          //   backgroundColor: Colors.blue,
          //   backgroundImage: AssetImage('assets/images/water_icon.jpg'),
          // ),
          title: Text(timeTxt),
          subtitle: Text(locationTxt),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Edit report information',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReportForm(reportId: reportId)));
                  //showReportPanel(context: context, reportId: reportId);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                tooltip: 'Delete report',
                onPressed: () {
                  DatabaseService().deleteReport(reportId);
                },
              ),
            ],
          ),
        ),
      ),
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
            return _getTile(
              DateFormat('yyyy-MM-dd – kk:mm')
                      .format(reports[index].time.toDate()) ??
                  '',
              reports[index].address ?? '',
              reports[index].rid,context
            );
          },
        ),
      );    
  }
}
