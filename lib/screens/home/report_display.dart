import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ufr/models/report.dart';
import 'package:ufr/screens/home/display_image.dart';
import 'package:ufr/screens/home/select_map_point.dart';
import 'package:ufr/shared/loading.dart';
import 'package:ufr/shared/modules.dart';

enum ImageStatusEnum {
  noImage,
  newImageCaptured,
  existingImage,
}

class ReportDisplay extends StatefulWidget {
  final ReportCls report;
  final String personName;

  const ReportDisplay(
      {super.key, required this.report, required this.personName});

  @override
  State<ReportDisplay> createState() => _ReportDisplayState();
}

class _ReportDisplayState extends State<ReportDisplay> {
  bool _loadingEffect = false;

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Report Information'),
          elevation: 0.0,
        ),
        body: _loadingEffect == true
            ? const Loading()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(children: [
                  Align(
                    child: Text(
                      'Report Time',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                      DateFormat('yyyy-MM-dd – kk:mm')
                          .format(widget.report.time.toDate()),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Address',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.address!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Cause',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.cause!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Diameter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.diameter.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                            widget.report.locationGeoPoint == null
                                ? ''
                                : "${widget.report.locationGeoPoint!.latitude} , ${widget.report.locationGeoPoint!.longitude}",
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                          icon: const Icon(Icons.gps_fixed),
                          onPressed: () {
                            try {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectMapPoint(
                                          initialGeoPoint:
                                              widget.report.locationGeoPoint!,
                                          useMode: SelectMapPointUseModeEnum
                                              .noSelect,
                                        )),
                              );
                            } catch (e) {
                              if (context.mounted) {
                                showSnackBarMessage(
                                    context, 'error occurred: $e');
                                Navigator.pop(context);
                              }
                            }
                          }),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Material',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.report.material!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  widget.report.imageURL != null
                      ? IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: () {
                            setState(() => _loadingEffect = true);
                            downloadFile(widget.report.imageURL!).then((file) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          DisplayImage(file)));
                              setState(() => _loadingEffect = false);
                            }).onError((e, stackTrace) {
                              setState(() => _loadingEffect = false);
                              if (context.mounted) {
                                showSnackBarMessage(
                                    context, 'error occurred: $e');
                                Navigator.pop(context);
                              }
                            });
                          })
                      : const Text('No image attached to this report',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'User name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(widget.personName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          child: const Text(
                            'Close',
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  ),
                ]),
              ));
  }
}
