import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ufr/screens/home/home_drawer.dart';
import 'package:provider/provider.dart';

import 'package:ufr/models/user.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_list%20rows.dart';
import 'package:ufr/screens/home/report_list_tiles.dart';
import 'package:ufr/services/database.dart';

import 'report_form.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _selectedIndex = 0;
  Widget _listWidget = ReportsAsTiles();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        _listWidget = ReportsAsTiles();
      }

      if (_selectedIndex == 1) {
        _listWidget = ReportsAsRows();
      }
    });
  }

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
            IconButton(
                icon: Icon(Icons.card_giftcard),
                tooltip: 'View as tiles',
                onPressed: () {}),
            IconButton(
                icon: Icon(Icons.table_view),
                tooltip: 'View as table',
                onPressed: () {}),
            IconButton(
                icon: Icon(Icons.map),
                tooltip: 'View as map',
                onPressed: () {}),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/water_pg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: _listWidget,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business),
              label: 'Business',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'School',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
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
