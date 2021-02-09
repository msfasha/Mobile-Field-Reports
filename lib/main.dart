import 'dart:async';

import 'package:ufr/screens/home/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ufr/services/firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  

  // FlutterError.onError = (FlutterErrorDetails details) {
  //   //this line prints the default flutter gesture caught exception in console
  //   FlutterError.dumpErrorToConsole(details);
  //   print("Error From INSIDE FRAME_WORK");
  //   print("----------------------");
  //   print("Error :  ${details.exception}");
  //   print("StackTrace :  ${details.stack}");
  // };

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
    print("Error FROM OUT_SIDE FRAMEWORK ");
    print("--------------------------------");
    print("Error :  $error");
    print("StackTrace :  $stackTrace");
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService.user,
      catchError: (context, e) {
        print('*#*#*#*#*#* : ' + e.toString());
        return null;
      },
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
      ),
    );
  }
}
