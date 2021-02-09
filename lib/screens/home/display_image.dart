import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';

enum fileStateEnum { FileDownloaded, FileDownloading, DownloadFileError }

class DisplayImage extends StatefulWidget {
  final String url;
  final File file;

  DisplayImage({this.file, this.url});

  @override
  _DisplayImageState createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage> {
  File _file;
  String _errorMessage;
  fileStateEnum _fileState = fileStateEnum.FileDownloading;
  
  resolveImage() async {
    if (widget.url != null) {
      //either a file or an error message will be returned
      dynamic result = await downloadImage(widget.url);
      
        if (result is File) {
        setState(() {
                  _fileState = fileStateEnum.FileDownloaded;
                });
          _file = result;
        } else if (_file is String) {
          setState(() {
              _fileState = fileStateEnum.DownloadFileError;
                    });
          _errorMessage = result;        
      }
    } else if (widget.file != null) {
      _file = widget.file;
      setState(() {        
        _fileState = fileStateEnum.FileDownloaded;
      });
    }
  }

  @override
  void initState() {
      // TODO: implement initState
      super.initState();
      resolveImage();
    }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Site image'),
      ),
      // ignore: missing_return
      body: Builder(builder: (context) {
        if (_fileState == fileStateEnum.FileDownloaded)
          return Image.file(_file, fit: BoxFit.cover);
        else if (_fileState == fileStateEnum.FileDownloading)
          return Loading();
        else if (_fileState == fileStateEnum.DownloadFileError)
          return Container(
            child: Text(_errorMessage),
          );
      }),
    );
  }
}
