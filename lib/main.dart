import 'dart:async';

import 'package:ufr/screens/home/wrapper.dart';
import 'package:ufr/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:ufr/shared/modules.dart';
import 'package:provider/provider.dart';
import 'package:ufr/models/user.dart';
import 'package:firebase_core/firebase_core.dart';

//Check this page for initializing firestore while loading
//https://stackoverflow.com/questions/63492211/no-firebase-app-default-has-been-created-call-firebase-initializeapp-in

// void main() async {
//   try {
//     WidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp().catchError((e) {
//       print('****** : ' + e.toString());
//     });

//     ErrorWidget.builder = (FlutterErrorDetails details) {
//       return Material(
//         child: Container(
//           color: Colors.purple,
//           alignment: Alignment.center,
//           child: Text(
//             'Something went wrong!',
//             style: TextStyle(fontSize: 20, color: Colors.white),
//           ),
//         ),
//       );
//     };

//     runApp(MyApp());
//   } on Exception catch (e) {
//     print('****** : ' + e.toString());
//     //AlertDialog(
//       //  title: Text("Error"), content: Text(e.toString() + st.toString()));
//     //return createErrorWidget(e, st);
//   }
// }

void main() async {
  try {
    print('');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FlutterError.onError = (FlutterErrorDetails details) {
      //this line prints the default flutter gesture caught exception in console
      //FlutterError.dumpErrorToConsole(details);
      print("Error From INSIDE FRAME_WORK");
      print("----------------------");
      print("Error :  ${details.exception}");
      print("StackTrace :  ${details.stack}");
    };

      //Displayed instead of read screen
      ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Scaffold(
            appBar: AppBar(title: Text(''),),
            body: SafeArea(
                        child: Text(
                  'Something went wrong, please try again or inform support if the problem persists!',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
            ),
          ),
        ),
      );
    };

    runZoned(() async {
      runApp(MyApp()); // starting point of app
    }, onError: (error, stackTrace) {
      print("Error FROM OUT_SIDE FRAMEWORK ");
      print("--------------------------------");
      print("Error :  $error");
      print("StackTrace :  $stackTrace");
    });
  } on Exception catch (e, st) {
    print(e.toString() + st.toString());
    return null;
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    try {
      return StreamProvider<User>.value(
        value: AuthService().user,
        catchError: (context, e) {
          print('****** : ' + e.toString());
          return null;
        },
        child: MaterialApp(
          theme: new ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
        ),
      );
    } on Exception catch (e, st) {
      print('****** : ' + e.toString());
      return createErrorWidget(e, st);
    }
  }
}
