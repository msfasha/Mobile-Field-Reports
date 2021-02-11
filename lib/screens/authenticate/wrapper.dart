import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/authenticate/sign_in.dart';
import 'package:ufr/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      final userProfile = Provider.of<UserProfile>(context);

      print('*****wrapper build called, user: ' + (userProfile?.userId ?? ''));

      if (userProfile == null) {
        print('null user');
        return SignIn();
      } else if (userProfile.userStatus == false) {
        print('deactiavted user');
        return SignIn();
      } else {
        print('active user');
        return Home();
      }
    } on Exception catch (e) {
      throw e;
    }
  }
}
