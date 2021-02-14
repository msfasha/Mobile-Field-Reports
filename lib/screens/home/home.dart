import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/home_drawer.dart';
import 'package:ufr/screens/home/report_entry.dart';
import 'package:ufr/screens/home/report_map_listing.dart';
import 'package:ufr/screens/home/report_tile_listing.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/shared/modules.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  _requestMapLocationPemmission() async {
    try {
      PermissionStatus locationPermissionStatus =
          await Permission.location.status;

      if (locationPermissionStatus != PermissionStatus.granted) {
        locationPermissionStatus = await Permission.location.request();

        if (locationPermissionStatus != PermissionStatus.granted)
          showSnackBarMessage(
              'No permission to use location services', reportFormScaffoldKey);

        setState(() {
          Globals.locationPerissionGranted =
              locationPermissionStatus == PermissionStatus.granted
                  ? true
                  : false;
        });
      }
    } on Exception catch (e) {
      showSnackBarMessage(e.toString(), reportFormScaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    _requestMapLocationPemmission();
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
                icon: Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Text("List"),
                    color: Colors.transparent,
                    textColor: Colors.white,
                    elevation: 0,
                  )),
                  Expanded(
                      child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              _selectedIndex = 1;
                            });
                          },
                          child: Text("Map"),
                          color: Colors.transparent,
                          textColor: Colors.white,
                          elevation: 0))
                ],
              ),
            )),
        body: _selectedIndex == 0 ? ReportTileListing() : ReportMapListing(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ReportEntry()));
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}
