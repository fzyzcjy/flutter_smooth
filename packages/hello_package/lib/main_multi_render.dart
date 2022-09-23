// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, avoid_print, unnecessary_import

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

void main() {
  print('==================== Dart main() start =======================');
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;

  // runApp(MyApp());

  // https://book.flutterchina.club/chapter14/paint.html#_14-5-1-flutter-%E7%BB%98%E5%88%B6%E5%8E%9F%E7%90%86
  final builder = SceneBuilder();
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = Rect.fromLTWH(0, 0, 500, 500);
  canvas.drawRect(
      Rect.fromLTWH(100, 100, 200, 200), Paint()..color = Colors.green);
  final pictureLayer = PictureLayer(rect);
  pictureLayer.picture = recorder.endRecording();
  final rootLayer = OffsetLayer();
  rootLayer.append(pictureLayer);
  final scene = rootLayer.buildScene(builder);

  print('call window.render start');
  window.render(scene);
  print('call window.render end');
}

// class MyApp extends StatefulWidget {
//   MyApp({Key? key}) : super(key: key);
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   var buildCount = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     buildCount++;
//     print('$runtimeType.build ($buildCount)');
//
//     if (buildCount < 5) {
//       Future.delayed(Duration(seconds: 1), () {
//         print('$runtimeType.setState after a second');
//         setState(() {});
//       });
//     }
//
//     return Container(
//       color: Colors.green[(1 + buildCount % 8) * 100],
//     );
//   }
// }
