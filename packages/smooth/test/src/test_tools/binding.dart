import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/src/binding.dart';
import 'package:smooth/src/service_locator.dart';

import 'proxy.dart';
import 'window.dart';
import 'window_render_capturer.dart';

// test the test-tool code
void main() {
  SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SmoothSchedulerBindingMixin.onWindowRender', (tester) async {
    final binding = SmoothAutomatedTestWidgetsFlutterBinding.instance;
    binding.window.setUpTearDown(
        physicalSizeTestValue: const Size(100, 50),
        devicePixelRatioTestValue: 1);

    final capturer = WindowRenderCapturer.autoRegister();

    // just a simple scene
    await tester.pumpWidget(DecoratedBox(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.green, width: 1)),
      child: Center(
        child: Container(width: 10, height: 10, color: Colors.green.shade200),
      ),
    ));

    expect(capturer.images.single,
        matchesGoldenFile('../goldens/binding/simple.png'));
  });
}

class SmoothAutomatedTestWidgetsFlutterBinding
    extends AutomatedTestWidgetsFlutterBinding
    with
        SmoothSchedulerBindingMixin,
        SmoothRendererBindingMixin,
        SmoothSchedulerBindingTestMixin {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;

    // NOTE see https://github.com/fzyzcjy/flutter_smooth/issues/48
    accuratePump = true;
  }

  static SmoothAutomatedTestWidgetsFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);
  static SmoothAutomatedTestWidgetsFlutterBinding? _instance;

  // ignore: prefer_constructors_over_static_methods
  static SmoothAutomatedTestWidgetsFlutterBinding ensureInitialized() {
    if (SmoothAutomatedTestWidgetsFlutterBinding._instance == null) {
      SmoothAutomatedTestWidgetsFlutterBinding();
    }
    return SmoothAutomatedTestWidgetsFlutterBinding.instance;
  }
}

mixin SmoothSchedulerBindingTestMixin on AutomatedTestWidgetsFlutterBinding {
  OnWindowRender? onWindowRender;

  @override
  TestWindow get window =>
      SmoothTestWindow(super.window, onRender: (s) => onWindowRender?.call(s));

  Duration? prevFrameTimeStamp;

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    super.handleBeginFrame(rawTimeStamp);

    final smoothActive = ServiceLocator.maybeInstance != null;
    if (smoothActive && prevFrameTimeStamp != null) {
      expect(
        (currentFrameTimeStamp - prevFrameTimeStamp!).inMicroseconds %
            kOneFrame.inMicroseconds,
        0,
        reason: 'frame timestamp should be multiples of kOneFrame, '
            'otherwise Smooth logic will be wrong '
            'currentFrameTimeStamp=$currentFrameTimeStamp '
            'prevFrameTimeStamp=$prevFrameTimeStamp ',
      );
    }

    prevFrameTimeStamp = currentFrameTimeStamp;
  }
}

typedef OnWindowRender = void Function(ui.Scene scene);

class SmoothTestWindow extends ProxyTestWindow implements TestWindow {
  final OnWindowRender onRender;

  const SmoothTestWindow(
    super._inner, {
    required this.onRender,
  });

  @override
  void render(ui.Scene scene) {
    onRender(scene);
    super.render(scene);
  }
}
