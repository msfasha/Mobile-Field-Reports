// import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:ufr/screens/home/wrapper.dart';
import 'package:ufr/shared/globals.dart';
import 'package:ufr/models/user_profile.dart';

import 'shared/aws_authentication_service.dart';
import 'shared/aws_data_service.dart';

void main() async {
  // add code below, it should be the first line in main method
  // otherwise, Firebase initialization will fail because we are using async in main!
  //https://stackoverflow.com/questions/57689492/flutter-unhandled-exception-servicesbinding-defaultbinarymessenger-was-accesse
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  FlutterError.onError = (FlutterErrorDetails details) {
    //this line prints the default flutter gesture caught exception in console
    FlutterError.dumpErrorToConsole(details);

    // logInFireStore(
    //   logType: LogTypeEnum.error,
    //   source: 'FlutterError.onError = (FlutterErrorDetails details)',
    //   message: TextTreeRenderer(
    //     wrapWidth: 100,
    //     wrapWidthProperties: 100,
    //     maxDescendentsTruncatableNode: 10,
    //   )
    //       .render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.error))
    //       .trimRight(),
    //   exception: details.exception,
    //   stacktrace: details.stack, context: null, reportId: '',
    // );
  };

  //Display instead of red screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('System Notification')),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Builder(
              builder: (context) {
                String err =
                    "\n${details.exception}\n----------\n${details.stack}";
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                      'Something went wrong, please try again.\n\nIf the problem persists, please call system support.$err',
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                );
              },
            ),
          ),
        ),
      ),
    );
  };

  runApp(const MyApp());
  // runZonedGuarded(() {
  //   runApp(MyApp());
  // }, // starting point of app
  //     (error, stackTrace) {
  //   print("Error FROM OUT_SIDE FRAMEWORK :  $error $stackTrace");
  //   logInFireStore(
  //     logType: LogTypeEnum.error,
  //     source: 'runZonedGuarded',
  //     exception: error,
  //     stacktrace: stackTrace,
  //   );
  // });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //fetchAgencies method will be called during the build method
  //the fetched values will be saved in a global static variable for future uses
  fetchAgencies() async {
    try {
      QuerySnapshot agenciesSnapShot = await DataService.agencies;
      if (agenciesSnapShot.size > 0) {
        Globals.agenciesSnapshot = agenciesSnapShot;
      }
    } catch (e) {
      Globals.agenciesSnapshot = null;
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //load agencies
    fetchAgencies();
    return StreamProvider<UserProfile?>.value(
      value: AuthenticationService.userStatusStream,
      catchError: (context, error) {
        return null;
      },
      initialData: null,
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: const Wrapper(),
      ),
    );
  }
}
