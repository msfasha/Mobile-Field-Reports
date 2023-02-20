import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/home/home_drawer.dart';
import 'package:ufr/screens/home/report_crud.dart';
import 'package:ufr/screens/home/report_map_listing.dart';
import 'package:ufr/screens/home/report_tile_listing.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/shared/modules.dart';

import '../../shared/aws_data_service.dart';
//import 'package:ufr/widgets/agency_dropdown.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTabIndex = 0;
  String? _selectedAgency;
  String? _title;
  UserProfile? _user;

  _requestMapLocationPermission() async {
    try {
      PermissionStatus locationPermissionStatus =
          await Permission.location.status;

      if (locationPermissionStatus != PermissionStatus.granted) {
        locationPermissionStatus = await Permission.location.request();

        if (locationPermissionStatus != PermissionStatus.granted) {
          if (context.mounted) {
            showSnackBarMessage(
                context, 'No permission to use location services');
          }
        }
      }

      Globals.locationPerissionGranted =
          locationPermissionStatus == PermissionStatus.granted ? true : false;
    } catch (e) {
      if (context.mounted) {
        showSnackBarMessage(context, 'error occurred: $e');
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _requestMapLocationPermission();
    //_user = Provider.of<UserProfile>(context);
    //_title = _user.agencyName;
  }

  @override
  Widget build(BuildContext context) {
    //called only on first build, to set the title value to the original agency of the user

    _user = Provider.of<UserProfile>(context);
    _title = _user!.agencyName ?? "_title";

    return StreamProvider<List<ReportCls>>.value(
      //if an agency is selected, then use it, otherwise use the user's original agency
      value: DataService.getReportsStream(_selectedAgency ?? _user!.agencyId),
      catchError: (context, e) {
        return [];
      },
      initialData: const [],
      child: Scaffold(
        key: homeScaffoldKey,
        drawer: const SafeArea(child: HomeDrawer()),
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                homeScaffoldKey.currentState!.openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            ),
            title: Text(_title!),
            elevation: 0.0,
            // actions: <Widget>[
            //   PopupMenuButton(
            //     itemBuilder: (context) => [
            //       (_user.userCategory == UserCategoryBaseEnum.sysAdmin.value)
            //           ? PopupMenuItem(child: AgencyDropDown(
            //               onChanged: (value) async {
            //                 _selectedAgency = value;
            //                 String selectAgencyName =
            //                     await DataService.getAgencyNameByAgencyId(
            //                         _selectedAgency);
            //                 setState(() {
            //                   _title = 'Viewing: ' + selectAgencyName;
            //                 });
            //               },
            //             ))
            //           : null,
            //       const PopupMenuItem(
            //           child: Text("Reports Time Period"), value: "get_time"),
            //     ],
            //     onSelected: (route) {
            //       //Navigator.push(context,
            //       //   MaterialPageRoute(builder: (context) => AppSettings()));
            //       // Note You must create respective pages for navigation
            //       //Navigator.pushNamed(context, route);
            //     },
            //   ),
            // ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: const Text("List"),
                  )),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: const Text("Map"),
                  ))
                ],
              ),
            )),
        body: _selectedTabIndex == 0
            ? const ReportTileListing()
            : const ReportMapListing(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReportCrudScreen(
                          report: null,
                        )));
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
