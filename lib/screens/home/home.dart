import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ufr/screens/home/home_drawer.dart';
import 'package:provider/provider.dart';

import 'package:ufr/models/user.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/report_list.dart';
import 'package:ufr/services/firebase.dart';
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
    final user = Provider.of<User>(context);

    return StreamProvider<List<Report>>.value(
      value: DatabaseService.getReportsStream(user.utilityId),
      catchError: (context, e) {
        print('######################');
        //return createErrorWidget(e, st);
        return [];
      }, 
      child: Scaffold(
                key: scaffoldKey,
                drawer: SafeArea(child: HomeDrawer()),
                appBar: AppBar(
                  leading: Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      );
                    },
                  ),
                  //title: Text(user.utilityName),
                  backgroundColor: Colors.blue[400],
                  elevation: 0.0,
                  actions: <Widget>[],
                ),
                body: Column(children: [
                  Container(
                    height: 30,
                    color: Colors.transparent,
                    child: ButtonBar(
                      alignment: MainAxisAlignment.center,
                      buttonHeight: 10,
                      children: <Widget>[
                        FlatButton(
                            child: Text('Tiles'),
                            color: Colors.blue,
                            onPressed: () {
                              _changeNotifier
                                  .changeView(ReportsViewTypeEnum.ViewAsTiles);
                            }),
                        FlatButton(
                          child: Text('Rows'),
                          color: Colors.blue,
                          onPressed: () {
                            setState(() {
                              _changeNotifier
                                  .changeView(ReportsViewTypeEnum.ViewAsRows);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  ChangeNotifierProvider(
                    create: (context) => _changeNotifier,
                    child: ReportsList(),
                  ),
                ]),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ReportForm()));
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.blue,
                ),
              ),
    );
  }
}
