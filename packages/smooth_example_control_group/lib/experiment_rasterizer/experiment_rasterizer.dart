import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smooth_example_control_group/experiment_rasterizer/bare_metal_util.dart';

// #6092
// ref [examples/layers/raw/spinning_square.dart]
void experimentRasterizerStandard() {
  var counter = 0;

  void beginFrame(timeStamp) {
    final scene = buildSceneFromPainter((canvas, size) {
      drawChessBoard(canvas, size, counter++);
    });
    window.render(scene);
    PlatformDispatcher.instance.scheduleFrame();
  }

  PlatformDispatcher.instance
    ..onBeginFrame = beginFrame
    ..scheduleFrame();
}
