import 'package:cloud_firestore/cloud_firestore.dart';

class Globals {
  static const List<int> diameterList = [
    50,
    63,
    75,
    80,
    100,
    110,
    125,
    150,
    180,
    200,
    250,
    300,
    350,
    400,
    450,
    500,
    550,
    600,
    650,
    700,
    750,
    800,
    850,
    900,
    950,
    1000,
    1050,
    1100,
    1150,
    1200,
    1250,
    1300,
    1350,
    1400,
    1450,
    1500,
    1550,
    1600,
    1650,
    1700,
    1750,
    1800,
    1850,
    1900,
    1950,
    2000,
    2050,
    2100,
    2150,
    2200,
    2250,
    2300,
    2350
  ];
  static const List<String> materialList = ['GI', 'ST', 'DI', 'PVC', 'HDPE'];
  static const List<String> causeList = [
    'High Pressure',
    'Negative Pressure',
    'Hit by Mistake',
    'Old Pipe',
    'Bad Installation'
  ];
  static bool locationPerissionGranted = false;
  static QuerySnapshot agenciesSnapshot;
}
