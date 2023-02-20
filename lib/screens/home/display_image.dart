import 'dart:io';
import 'package:flutter/material.dart';

class DisplayImage extends StatelessWidget {
  final File file;

  const DisplayImage(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar:  AppBar(
          title:  const Text('Site image'),
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
