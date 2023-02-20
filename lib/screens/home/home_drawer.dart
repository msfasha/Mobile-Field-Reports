import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/authenticate/change_password.dart';
import 'package:ufr/screens/authenticate/user_management.dart';
import 'package:ufr/screens/home/export.dart';
import 'package:ufr/shared/modules.dart';
import 'package:provider/provider.dart';

import '../../shared/aws_authentication_service.dart';
import '../../shared/aws_data_service.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  late Widget _exportTitle;

  @override
  void initState() {
    _exportTitle = const Text('Export to CSV');
    super.initState();
  }

  _logout() async {
    try {
      await AuthenticationService.signOut();
    } catch (e) {
      if (context.mounted) {
        showSnackBarMessage(context, 'error occurred: $e');
      }
    }
  }

  _exitApplication() async {
    try {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } catch (e, s) {
      logInFireStore(
          exception: e,
          stacktrace: s,
          context: context,
          source: '_exitApplication',
          logType: LogTypeEnum.info,
          message: '',
          reportId: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProfile>(context);

    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user.personName),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              child: Text(
                user.email.characters.first,
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: _exportTitle,
            onTap: () {
              setState(() {
                _exportTitle = SpinKitThreeBounce(
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20.0,
                );
              });

              ExportFromFireStore.exportToCSV(user.agencyId, context);
              // .then((value) => Navigator.pop(context));
            },
          ),
          (user.userCategory == UserCategoryBaseEnum.sysAdmin.value)
              ? ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Manage users'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserManagement()));
                  })
              : Container(),
          ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Change Password'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePassword()));
              }),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showMessageDialog(context, "ME Application");
            },
          ),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Logout'),
              onTap: _logout),
          ListTile(
            leading: const Icon(Icons.power_settings_new),
            title: const Text('Exit'),
            onTap: _exitApplication,
          ),
        ],
      ),
    );
  }
}
