import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

    logInFireStore(
      logType: LogTypeEnum.Error,
      source: 'FlutterError.onError = (FlutterErrorDetails details)',
      message: TextTreeRenderer(
        wrapWidth: 100,
        wrapWidthProperties: 100,
        maxDescendentsTruncatableNode: 10,
      )
          .render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.error))
          .trimRight(),
      exception: details.exception,
      stacktrace: details.stack,
    );
  };

  //Displayed instead of red screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('System Notification')),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Builder(
              builder: (context) {
                return Text(
                    'Something went wrong, please try again.\n\nIf the problem persists, please call system support.',
                    style: TextStyle(fontSize: 16, color: Colors.grey));
              },
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
    logInFireStore(
      logType: LogTypeEnum.Error,
      source: 'runZonedGuarded',
      exception: error,
      stacktrace: stackTrace,
    );
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
      catchError: (context, error) {
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
