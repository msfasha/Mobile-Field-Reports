import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ufr/models/user_profile.dart';
import 'package:ufr/screens/authenticate/change_password.dart';
import 'package:ufr/screens/home/user_management.dart';
import 'package:ufr/shared/firebase_services.dart';
import 'package:ufr/shared/export.dart';
import 'package:ufr/shared/modules.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  Widget _exportTitle;

  @override
  void initState() {
    _exportTitle = Text('Export to CSV');
    super.initState();
  }

  _logout() async {
    try {
      await AuthService.signOut();
    } on Exception catch (e) {
      //TODO need to remove print to something else
      print(e.toString());
    }
  }

  _exitApplication() async {
    try {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } on Exception catch (e) {
      print(e.toString());
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
            accountName: Text(user.personName ?? ''),
            accountEmail: Text(user.email) ?? '',
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).platform == TargetPlatform.iOS
                  ? Colors.blue
                  : Colors.white,
              child: Text(
                user.email.characters.first ?? '',
                style: TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.save),
            title: _exportTitle,
            onTap: () async {
              setState(() {
                _exportTitle = SpinKitThreeBounce(
                  color: Colors.blue,
                  size: 20.0,
                );
              });

              ExportFromFireStore.exportToCSV(user.agencyId, context);

              Navigator.pop(context);
            },
          ),
          (user.userCategory == UserCategoryBaseEnum.SysAdmin.value)
              ? ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text('Manage users'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserManagement()));
                  })
              : Container(),
          ListTile(
              leading: Icon(Icons.info),
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ChangePassword()));
              }),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              showMessageDialog(context, "ME Application");
            },
          ),
          ListTile(
              leading: Icon(Icons.person),
              title: Text('Logout'),
              onTap: _logout),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Exit'),
            onTap: _exitApplication,
          ),
        ],
      ),
    );
  }
}
