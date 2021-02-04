import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(2.0))),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(2.0))),
);

String validateEmail(String value) {
    if (value == null) {
      return 'Please enter mail';
    }

    if (value.isEmpty) {
      return 'Please enter mail';
    }

    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
}

Widget createErrorWidget(dynamic exception, StackTrace stackTrace) {
  final FlutterErrorDetails details = FlutterErrorDetails(
    exception: exception,
    stack: stackTrace,
    library: 'widgets library',
    context: ErrorDescription('building'),
  );
  FlutterError.reportError(details);
  return ErrorWidget.builder(details);
}

showADialog(BuildContext context, String content) {
  showDialog(
      context: context,
      builder: (_) {
        if (Platform.isAndroid) {
          return new AlertDialog(
            title: new Text("Utility Reporting Tool"),
            content: new Text(content) ?? '',
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        } else if (Platform.isIOS) {
          return new CupertinoAlertDialog(
            title: new Text("Utility Reporting Tool"),
            content: new Text(content ?? ''),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
        throw '';
      });
}

class ReportsViewTypeChangeNotifier extends ChangeNotifier {
  ReportsViewTypeEnum reportViewType;
  void changeView(ReportsViewTypeEnum reportViewType) {
    this.reportViewType = reportViewType;
    notifyListeners();
  }
}

enum ReportsViewTypeEnum { 
   ViewAsTiles, 
   ViewAsRows, 
   ViewInMap,    
}

enum CrudOperationTypeEnum { 
   Create, 
   Update}

showSnackBarMessage(String message)
{
  ScaffoldMessenger.of(scaffoldKey.currentContext).showSnackBar(SnackBar(
                                  content: Text(message),
                                  duration: Duration(milliseconds: 1500),
                                ));    
}

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
