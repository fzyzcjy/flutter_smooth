import 'dart:io';
import 'dart:ui';

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

// https://github.com/fzyzcjy/yplusplus/issues/6092#issuecomment-1272429116
void experimentRasterizerTwoRenderZeroRender() {
  var counter = 0;

  void beginFrame(timeStamp) {
    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    // roughly make it later than first vsync
    sleep(const Duration(milliseconds: 22));

    PlatformDispatcher.instance.scheduleFrame();
  }

  PlatformDispatcher.instance
    ..onBeginFrame = beginFrame
    ..scheduleFrame();
}

// https://github.com/fzyzcjy/yplusplus/issues/6092#issuecomment-1272435382
void experimentRasterizerAnotherTwoRenderZeroRender() {
  var counter = 0;

  void beginFrame(timeStamp) {
    sleep(const Duration(milliseconds: 13));

    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    PlatformDispatcher.instance.scheduleFrame();
  }

  PlatformDispatcher.instance
    ..onBeginFrame = beginFrame
    ..scheduleFrame();
}

// https://github.com/fzyzcjy/yplusplus/issues/6092#issuecomment-1272436276
void experimentRasterizerTwoRenderZeroRenderThirdExample() {
  var counter = 0;

  void beginFrame(timeStamp) {
    sleep(const Duration(milliseconds: 4));

    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    sleep(const Duration(milliseconds: 22));

    PlatformDispatcher.instance.scheduleFrame();
  }

  PlatformDispatcher.instance
    ..onBeginFrame = beginFrame
    ..scheduleFrame();
}

// https://github.com/fzyzcjy/yplusplus/issues/6092#issuecomment-1272436884
void experimentRasterizerTwoRenderZeroRenderFourthExample() {
  var counter = 0;

  void beginFrame(timeStamp) {
    sleep(const Duration(milliseconds: 13));

    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    sleep(const Duration(milliseconds: 10));

    {
      final scene = buildSceneFromPainter((canvas, size) {
        drawChessBoard(canvas, size, counter++);
      });
      window.render(scene);
    }

    PlatformDispatcher.instance.scheduleFrame();
  }

  PlatformDispatcher.instance
    ..onBeginFrame = beginFrame
    ..scheduleFrame();
}
