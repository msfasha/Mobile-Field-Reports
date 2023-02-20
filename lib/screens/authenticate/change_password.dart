import 'package:flutter/material.dart';

class ChangePassword extends StatelessWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Passowrd'),
      ),
      // ignore: missing_return
      body: ListView(
        children: const [
          Text('New password'),
          Text('ReEnter Password'),
          Text('Submit'),
        ],
      ),
    );
  }
}
