import 'package:flutter/material.dart';
import 'package:ufr/screens/authenticate/register.dart';
import 'package:ufr/screens/authenticate/sign_in.dart';
import 'package:ufr/shared/modules.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (showSignIn) {
        return SignIn(toggleView: toggleView);
      } else {
        return Register(toggleView: toggleView);
      }
    } on Exception catch (e, st) {
      AlertDialog(
          title: Text("Error"), content: Text(e.toString() + st.toString()));
      return createErrorWidget(e, st);
    }
  }
}
