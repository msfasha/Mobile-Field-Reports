import 'package:flutter/material.dart';

class UserManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Users Management'),
      ),
      // ignore: missing_return
      body: ListView(
        children: [
          Text('Select Organization'),
          Text('Users List'),
        ],
      ),
    );
  }
}
