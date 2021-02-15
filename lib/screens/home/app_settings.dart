import 'package:flutter/material.dart';

class AppSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Application Settings'),
      ),
      // ignore: missing_return
      body: ListView(
        children: [
          Text('Select Agency'),
          Text('Year'),
          Text('Month'),
        ],
      ),
    );
  }
}
