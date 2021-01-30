import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:ufr/models/user.dart';
import 'package:ufr/services/auth.dart';
import 'package:ufr/shared/export.dart';
import 'package:ufr/shared/modules.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

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
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              showADialog(context, "Under Construction");
            },
          ),         
          ListTile(
            leading: Icon(Icons.save),
            title: Text('Export to CSV'),
            onTap: () async {
              try {                
                String result = await ExportFromFireStore.exportToCSV();                
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text(result),
                  duration: Duration(milliseconds: 1500),
                ));
                Navigator.pop(context);
              } on Exception catch (e) {
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                    duration: Duration(milliseconds: 1500)));
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              showADialog(context, "ME Application");
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Logout'),
            onTap: () async {
                await AuthService().signOut();
              },            
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Exit'),
            onTap: () async {
              SystemNavigator.pop();                
              if (Platform.isAndroid) {
                await AuthService().signOut();
                Future.delayed(const Duration(milliseconds: 1000), () {
                  exit(0);
                });
              } else if (Platform.isIOS) {
                await AuthService().signOut();
                exit(0);
              }
            },
          ),
        ],
      ),
    );
  }
}
