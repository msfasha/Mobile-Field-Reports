import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ufr/screens/authenticate/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/globals.dart';
import 'models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = (FlutterErrorDetails details) {
    //this line prints the default flutter gesture caught exception in console
    FlutterError.dumpErrorToConsole(details);
    print(
        "Error From INSIDE FRAME_WORK :  ${details.exception} ${details.stack}");
  };

  //Displayed instead of red screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Scaffold(
          appBar: AppBar(
            title: Text(''),
          ),
          body: SafeArea(
            child: Text(
              'Something went wrong, please try again or inform support if the problem persists!' +
                  details.exception.toString(),
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  };

//runApp(MyApp());
  runZonedGuarded(() {
    runApp(MyApp());
  }, // starting point of app
      (error, stackTrace) {
    print("Error FROM OUT_SIDE FRAMEWORK :  $error $stackTrace");
  });
}

class MyApp extends StatelessWidget {
  getAgencies() async {
    try {
      QuerySnapshot agenciesSnapShot = await DataService.agencies;
      if (agenciesSnapShot.size > 0)
        Globals.agenciesSnapshot = agenciesSnapShot;
    } catch (e) {
      Globals.agenciesSnapshot = null;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //get agencies
    getAgencies();
    return StreamProvider<UserProfile>.value(
      value: AuthService.user,
      catchError: (context, e) {
        print('MyApp Error: ' + e.toString());
        return null;
      },
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
