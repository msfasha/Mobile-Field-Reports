import 'dart:io';
import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  final File file;

  DisplayImage(this.file);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Site image'),
      ),
      // ignore: missing_return
      body: Image.file(file, fit: BoxFit.cover),
    );
  }
}
