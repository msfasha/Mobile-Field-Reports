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
        body: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.file(
            file,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fitWidth,
          ),
        ));
  }
}
