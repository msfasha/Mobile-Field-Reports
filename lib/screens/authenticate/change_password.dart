import 'package:flutter/material.dart';

class ChangePassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Change Passowrd'),
      ),
      // ignore: missing_return
      body: ListView(
        children: [
          Text('New password'),
          Text('ReEnter Password'),
          Text('Submit'),
        ],
      ),
    );
  }
}
