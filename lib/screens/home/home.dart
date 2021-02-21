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
import 'package:ufr/widgets/agency_dropdown.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedTabIndex = 0;
  String _selectedAgency;
  String _title;
  UserProfile _user;

  _requestMapLocationPemmission() async {
    try {
      PermissionStatus locationPermissionStatus =
          await Permission.location.status;

      if (locationPermissionStatus != PermissionStatus.granted) {
        locationPermissionStatus = await Permission.location.request();

        if (locationPermissionStatus != PermissionStatus.granted)
          showSnackBarMessage(
              'No permission to use location services', reportFormScaffoldKey);
      }

      Globals.locationPerissionGranted =
          locationPermissionStatus == PermissionStatus.granted ? true : false;
    } on Exception catch (e) {
      showSnackBarMessage(
          'error occured: ' + e.toString(), reportFormScaffoldKey);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestMapLocationPemmission();
    //_user = Provider.of<UserProfile>(context);
    //_title = _user.agencyName;
  }

  @override
  Widget build(BuildContext context) {
    //called only on first build, to set the title value to the original agency of the user
    if (_title == null) {
      _user = Provider.of<UserProfile>(context);
      _title = _title == null ? _user.agencyName : _title;
    }

    return StreamProvider<List<Report>>.value(
      //if an agency is selected, then use it, otherwise use the user's original agency
      value: DataService.getReportsStream(_selectedAgency ?? _user.agencyId),
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
            title: Text(_title),
            elevation: 0.0,
            actions: <Widget>[
              PopupMenuButton(
                itemBuilder: (BuildContext bc) => [
                  (_user.userCategory == UserCategoryBaseEnum.SysAdmin.value)
                      ? PopupMenuItem(
                          child: AgencyDropDown(
                          agencyId:
                              _selectedAgency, //make sure this is not static
                          onChanged: (value) async {
                            _selectedAgency = value;
                            String selectAgencyName =
                                await DataService.getAgencyNameByAgencyId(
                                    _selectedAgency);
                            setState(() {
                              _title = 'Viewing: ' + selectAgencyName;
                            });
                          },
                        ))
                      : null,
                  PopupMenuItem(
                      child: Text("Reports Time Period"), value: "get_time"),
                ],
                onSelected: (route) {
                  //Navigator.push(context,
                  //   MaterialPageRoute(builder: (context) => AppSettings()));
                  // Note You must create respective pages for navigation
                  //Navigator.pushNamed(context, route);
                },
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
                        _selectedTabIndex = 0;
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
                              _selectedTabIndex = 1;
                            });
                          },
                          child: Text("Map"),
                          color: Colors.transparent,
                          textColor: Colors.white,
                          elevation: 0))
                ],
              ),
            )),
        body: _selectedTabIndex == 0 ? ReportTileListing() : ReportMapListing(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ReportEntry()));
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
