// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  print('==================== Dart main() start =======================');
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    print('$runtimeType.build ($buildCount)');

    if (buildCount < 5) {
      Future.delayed(Duration(seconds: 1), () {
        print('$runtimeType.setState after a second');
        setState(() {});
      });
    }

    return Container(
      color: Colors.green[(1 + buildCount % 8) * 100],
    );
  }
}
