import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/authenticate/sign_in.dart';
import 'package:ufr/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile?>(context);

    if ((userProfile == null) || (userProfile.userStatus == false)) {
      return const SignIn();
    } else {
      return const Home();
    }
  }
}
