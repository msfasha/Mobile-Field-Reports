import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/authenticate/sign_in.dart';
import 'package:ufr/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile>(context);

    if (userProfile == null) {
      return SignIn();
    } else if (userProfile.userStatus == false) {
      return SignIn();
    } else {
      return Home();
    }
  }
}
