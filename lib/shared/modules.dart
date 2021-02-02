import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:ufr/screens/home/report_form.dart';
import 'package:ufr/shared/constants.dart';

void showReportPanel({BuildContext context, String reportId}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(          
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal:10.0),
          child: ReportForm(reportId :reportId),
        );
      });
}

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),                        
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(2.0))    
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(2.0))    
  ),
);

String validateEmail(String value) {
  try {
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
  } on Exception catch (e) {
    throw e;
  }
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
            title: new Text("Ministry of Water and Irregation, USAID 2021"),
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
            title: new Text("Ministry of Water and Irregation, USAID 2021"),
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
