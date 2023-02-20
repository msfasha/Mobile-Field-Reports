import 'package:flutter/material.dart';

class AppSettings extends StatelessWidget {
  const AppSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title:  const Text('Application Settings'),
      ),
      // ignore: missing_return
      body: ListView(
        children: const [
          Text('Year'),
          Text('Month'),
        ],
      ),
    );
  }
}
