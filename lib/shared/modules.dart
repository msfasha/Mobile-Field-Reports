import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ReportsViewTypeEnum {
  viewAsTiles,
  viewAsRows,
  viewInMap,
}

enum CrudOperationTypeEnum { create, update }

enum ImageCapturingMethodEnum { camera, photoLibrary }

enum UserCategoryBaseEnum { sysAdmin, user }

extension UserCategoryEnum on UserCategoryBaseEnum {
  String get value {
    switch (this) {
      case UserCategoryBaseEnum.sysAdmin:
        return 'SysAdmin';
      case UserCategoryBaseEnum.user:
        return 'User';
    }
  }
}

enum OperationResultCodeEnum { success, error }

class OperationResult {
  OperationResultCodeEnum? operationCode;
  String? message;
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

String? validateEmail(String? value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern.toString());

  if (value == null) {
    return 'Please enter mail';
  } else if (value.isEmpty) {
    return 'Please enter mail';
  } else if (!regex.hasMatch(value)) {
    return 'Enter Valid Email';
  } else {
    return null;
  }
}

Future<File> downloadFile(String url) async {
  try {
    final Reference ref = FirebaseStorage.instance.ref().child(url);

    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/temp-${ref.name}');
    if (tempFile.existsSync()) await tempFile.delete();

    await ref.writeToFile(tempFile);

    return tempFile;
  } catch (e) {
    rethrow;
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
          // ignore: unnecessary_new
          return new AlertDialog(
            title: const Text("Utility Reporting Tool"),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        } else if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: const Text("Utitity Reporting Tool"),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
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
    final VoidCallback func1,
    final VoidCallback func2) {
  showDialog(
      context: context,
      builder: (_) {
        if (Platform.isAndroid) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                onPressed: func1,
                child: Text(buttonOneTitle),
              ),
              TextButton(
                onPressed: func2,
                child: Text(buttonTwoTitle),
              )
            ],
          );
        } else if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              TextButton(
                onPressed: func1,
                child: Text(buttonOneTitle),
              ),
              TextButton(
                onPressed: func2,
                child: Text(buttonTwoTitle),
              )
            ],
          );
        }
        throw '';
      });
}

class ReportsViewTypeChangeNotifier extends ChangeNotifier {
  ReportsViewTypeEnum reportViewType = ReportsViewTypeEnum.viewAsRows;
  void changeView(ReportsViewTypeEnum reportViewType) {
    this.reportViewType = reportViewType;
    notifyListeners();
  }
}

showSnackBarMessage(BuildContext context, String message) {
  SnackBar snackBar = SnackBar(
    content: Text(message),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  Navigator.pop(context);
}

// showSnackBarMessage(String content, GlobalKey<ScaffoldState> scaffoldKey) {
//   try {
//     // if (scaffoldKey.currentState.mounted)
//     //   scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(content)));
//   } catch (e) {
//     if (kDebugMode) {
//       print('Error occurred in ShowSnackBar: ${e.toString()}');
//     }
//   }
// }

// final GlobalKey<ScaffoldState> homeScaffoldKey = GlobalKey<ScaffoldState>();
// final GlobalKey<ScaffoldState> reportFormScaffoldKey =
//     GlobalKey<ScaffoldState>();
// final GlobalKey<ScaffoldState> customMapScafoldKey = GlobalKey<ScaffoldState>();
// final GlobalKey<ScaffoldState> registerScafoldKey = GlobalKey<ScaffoldState>();
// final GlobalKey<ScaffoldState> userManagementScafoldKey =
//     GlobalKey<ScaffoldState>();
