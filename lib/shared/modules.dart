import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ReportsViewTypeEnum {
  ViewAsTiles,
  ViewAsRows,
  ViewInMap,
}

enum CrudOperationTypeEnum { Create, Update }
enum ImageCapturingMethodEnum { Camera, PhotoLibrary }

enum UserCategoryBaseEnum { SysAdmin, User }

extension UserCategoryEnum on UserCategoryBaseEnum {
  String get value {
    switch (this) {
      case UserCategoryBaseEnum.SysAdmin:
        return 'SysAdmin';
      case UserCategoryBaseEnum.User:
        return 'User';
      default:
        return null;
    }
  }
}

enum OperationResultCodeEnum { Success, Error }

class OperationResult {
  OperationResultCodeEnum operationCode;
  String message;
  dynamic content;

  OperationResult({this.operationCode, this.message, this.content});
}

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

dynamic downloadFile(String url) async {
  try {
    final Reference ref = FirebaseStorage.instance.ref().child(url);

    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/temp-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    return tempFile;
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

showMessageDialog(BuildContext context, String content) {
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
            title: new Text("Utitity Reporting Tool"),
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

showTwoButtonDialog(
    BuildContext context,
    String title,
    String content,
    String buttonOneTitle,
    String buttonTwoTitle,
    Function func1,
    Function func2) {
  showDialog(
      context: context,
      builder: (_) {
        if (Platform.isAndroid) {
          return AlertDialog(
            title: new Text(title),
            content: new Text(content) ?? '',
            actions: <Widget>[
              FlatButton(
                child: Text(buttonOneTitle),
                onPressed: func1,
              ),
              FlatButton(
                child: Text(buttonTwoTitle),
                onPressed: func2,
              )
            ],
          );
        } else if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: new Text(title),
            content: new Text(content) ?? '',
            actions: <Widget>[
              FlatButton(
                child: Text(buttonOneTitle),
                onPressed: func1,
              ),
              FlatButton(
                child: Text(buttonTwoTitle),
                onPressed: func2,
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

showSnackBarMessage(String content, GlobalKey<ScaffoldState> scaffoldKey) {
  try {
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(content)));
  } on Exception catch (e) {
    print('Error occured in ShowSnackBar: ${e.toString()}');
  }
}

final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> reportFormScaffoldKey =
    GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> customMapScafoldKey = GlobalKey<ScaffoldState>();
final GlobalKey<ScaffoldState> registerScafoldKey = GlobalKey<ScaffoldState>();
