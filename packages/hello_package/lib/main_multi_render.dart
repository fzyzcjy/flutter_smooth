// ignore_for_file: avoid_print, prefer_const_constructors

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

var frameCount = 0;

void beginFrame(Duration timeStamp) {
  frameCount++;
  print('onBeginFrame start ($frameCount)');

  // https://book.flutterchina.club/chapter14/paint.html#_14-5-1-flutter-%E7%BB%98%E5%88%B6%E5%8E%9F%E7%90%86
  final builder = SceneBuilder();
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);
  final rect = Rect.fromLTWH(0, 0, 500, 500);
  canvas.drawRect(Rect.fromLTWH(100, 100, 200, 200),
      Paint()..color = Colors.green[(1 + frameCount % 8) * 100]!);
  final pictureLayer = PictureLayer(rect);
  pictureLayer.picture = recorder.endRecording();
  final rootLayer = OffsetLayer();
  rootLayer.append(pictureLayer);
  final scene = rootLayer.buildScene(builder);

  print('call window.render start');
  window.render(scene);
  print('call window.render end');

  Future.delayed(const Duration(seconds: 1), () {
    if (frameCount < 5) {
      print('call scheduleFrame start');
      PlatformDispatcher.instance.scheduleFrame();
      print('call scheduleFrame end');
    }
  });

  print('onBeginFrame end');
}

// This function is the primary entry point to your application. The engine
// calls main() as soon as it has loaded your code.
void main() {
  print('==================== Dart main() start =======================');
  debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;

  // The engine calls onBeginFrame whenever it wants us to produce a frame.
  PlatformDispatcher.instance.onBeginFrame = beginFrame;

  // Here we kick off the whole process by asking the engine to schedule a new
  // frame. The engine will eventually call onBeginFrame when it is time for us
  // to actually produce the frame.
  print('main call scheduleFrame start');
  PlatformDispatcher.instance.scheduleFrame();
  print('main call scheduleFrame end');
}
