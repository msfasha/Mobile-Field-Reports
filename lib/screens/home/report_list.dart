import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufr/services/database.dart';
import 'package:ufr/shared/constants.dart';
import 'package:ufr/shared/modules.dart';

typedef Widget ListingItemCreator(String s1, String s2, String s3);

class ReportsList extends StatefulWidget {
  ReportsList();

  @override
  _ReportsListState createState() => _ReportsListState();
}

class _ReportsListState extends State<ReportsList> {
  _ReportsListState();

  //Widget _mainDisplayWidget;
  ListingItemCreator _lic;

  @override
  void initState() {
    super.initState();
  }

  Widget _tileWidget(String timeTxt, String locationTxt, String reportId) {
    return Card(
      margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.0,
          backgroundColor: Colors.blue,
          backgroundImage: AssetImage('assets/images/water_icon.jpg'),
        ),
        title: Text(timeTxt,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            )),
        subtitle: Text(locationTxt,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arial',
            )),
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
                        builder: (context) => ReportForm(reportId: reportId)));
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
    );
  }

  Widget _rowWidget(String timeTxt, String locationTxt, String reportId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(children: [
            Expanded(
              flex: 6,
              child: Text(timeTxt,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial',
                  )),
            ),
            Expanded(
              flex: 4,
              child: Text(locationTxt,
                  style: TextStyle(
                    fontSize: 14,
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
                          builder: (context) =>
                              ReportForm(reportId: reportId)));
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
        ),
        Divider(
          thickness: 1,
          color: Colors.grey,
          indent: 10,
          endIndent: 10,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reports = Provider.of<List<Report>>(context);
    if (reports == null) return Text('');

    return Expanded(
      child: Consumer<ReportsViewTypeChangeNotifier>(
          // ignore: missing_return
          builder: (context, viewType, child) {
        if (viewType.reportViewType == ReportsViewTypeEnum.ViewAsTiles) {
          return ListView.builder(
            itemCount: reports.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _tileWidget(
                DateFormat('yyyy-MM-dd – kk:mm')
                        .format(reports[index].time.toDate()) ??
                    '',
                reports[index].address ?? '',
                reports[index].rid,
              );
            },
          );
        } else if (viewType.reportViewType == ReportsViewTypeEnum.ViewAsRows) {
          return ListView.builder(
            itemCount: reports.length,
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _rowWidget(
                DateFormat('yyyy-MM-dd – kk:mm')
                        .format(reports[index].time.toDate()) ??
                    '',
                reports[index].address ?? '',
                reports[index].rid,
              );
            },
          );
        } else
          return Text('');
      }),
    );
  }
}
