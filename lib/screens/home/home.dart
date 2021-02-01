import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ufr/screens/home/home_drawer.dart';
import 'package:provider/provider.dart';

import 'package:ufr/models/user.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_list.dart';
import 'package:ufr/services/database.dart';

import 'report_form.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return StreamProvider<List<Report>>.value(
      value: DatabaseService().getReports(user.utilityId),
      catchError: (context, e) {
        AlertDialog(title: Text("Error"), content: Text(e.toString()));
        //return createErrorWidget(e, st);
        return [];
      },
      child: Scaffold(
        drawer: SafeArea(child: HomeDrawer()),
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          //title: Text(user.utilityName),
          backgroundColor: Colors.blue[400],
          elevation: 0.0,
          actions: <Widget>[
            
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage('assets/images/water_pg.png'),
            //   fit: BoxFit.cover,
            // ),
          ),
          child: ReportsList(),
        ),       
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            try {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReportForm()));
            } on Exception catch (e, st) {
              AlertDialog(
                  title: Text("Error"),
                  content: Text(e.toString() + st.toString()));
              //return createErrorWidget(e, st);
            }
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
