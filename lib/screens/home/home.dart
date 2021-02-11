import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/home_drawer.dart';
import 'package:provider/provider.dart';

import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_list.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/modules.dart';

import 'report_form.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ReportsViewTypeChangeNotifier _changeNotifier;

  @override
  void initState() {
    _changeNotifier = ReportsViewTypeChangeNotifier();
    _changeNotifier.changeView(ReportsViewTypeEnum.ViewAsTiles);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

    return StreamProvider<List<Report>>.value(
      value: DataService.getReportsStream(user.organizationId),
      catchError: (context, e) {
        return [];
      },
      child: Scaffold(
        key: homeScaffoldKey,
        drawer: SafeArea(child: HomeDrawer()),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              homeScaffoldKey.currentState.openDrawer();
            },
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
          title: Text(user.organizationName),
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.view_agenda),
              onPressed: () {
                setState(() {
                  _changeNotifier.changeView(ReportsViewTypeEnum.ViewAsTiles);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.table_rows),
              onPressed: () {
                setState(() {
                  _changeNotifier.changeView(ReportsViewTypeEnum.ViewAsRows);
                });
              },
            ),
          ],
        ),
        body: Column(children: [
          ChangeNotifierProvider(
            create: (context) => _changeNotifier,
            child: ReportsList(),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => ReportForm()));
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
