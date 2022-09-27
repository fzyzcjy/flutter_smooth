import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var count = 0;

  @override
  Widget build(BuildContext context) {
    // NOTE
    sleep(const Duration(milliseconds: 17));

    count++;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('$count ${DateTime.now()}'),
        ),
      ),
    );
  }
}
