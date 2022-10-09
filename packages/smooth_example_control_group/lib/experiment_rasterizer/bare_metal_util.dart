import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

Scene buildSceneFromPainter(void Function(Canvas, Size) painter) {
  final paintBounds =
      Offset.zero & (window.physicalSize / window.devicePixelRatio);

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, paintBounds);

  canvas.drawRect(paintBounds, Paint()..color = Colors.white);
  painter(canvas, paintBounds.size);

  final picture = recorder.endRecording();

  final double devicePixelRatio = window.devicePixelRatio;
  final Float64List deviceTransform = Float64List(16)
    ..[0] = devicePixelRatio
    ..[5] = devicePixelRatio
    ..[10] = 1.0
    ..[15] = 1.0;
  final sceneBuilder = SceneBuilder()
    ..pushTransform(deviceTransform)
    ..addPicture(Offset.zero, picture)
    ..pop();

  return sceneBuilder.build();
}

void drawChessBoard(Canvas canvas, Rect bounds, int value) {
  const cols = 4;
  const rows = 4;
  const colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  value %= cols * rows;
  final x = value % cols;
  final y = value ~/ cols;

  final gridWidth = bounds.width / cols;
  final gridHeight = bounds.height / rows;

  canvas.drawRect(
    Rect.fromLTWH(
      bounds.left + gridWidth * x,
      bounds.top + gridWidth * y,
      gridWidth,
      gridHeight,
    ),
    Paint() //
      ..color = colors[x],
  );
}
