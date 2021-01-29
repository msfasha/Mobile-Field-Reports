import 'package:flutter/material.dart';
import 'package:ufr/services/database.dart';
import 'package:ufr/shared/modules.dart';

class ReportTile extends StatelessWidget {
  final String timeTxt;
  final String locationTxt;
  final String reportId;

  ReportTile({this.timeTxt, this.locationTxt, this.reportId});

  @override
  Widget build(BuildContext context) {
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
                  showReportPanel(context: context, reportId: reportId);
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
}
