import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

//runApp(MyApp());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AuthService.signInWithEmailAndPassword('a@a.com', '123456');
    DataService.getReport('By6GNkyumNBiffspsY5c').then((val) {
      print(val.address);
    });
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Loading(),
    );
  }
}
