import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth/smooth.dart';
import 'package:smooth/src/binding.dart'; // ignore: implementation_imports
import 'package:smooth/src/service_locator.dart'; // ignore: implementation_imports
import 'package:smooth_dev/src/proxy.dart';

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
  @override
  void initInstances() {
    super.initInstances();
    setUp(() => _testFrameNumber = 0);
    tearDown(() => _testFrameNumber = null);
  }

  OnWindowRender? onWindowRender;

  @override
  TestWindow get window =>
      SmoothTestWindow(super.window, onRender: (s) => onWindowRender?.call(s));

  int get testFrameNumber => _testFrameNumber!;
  int? _testFrameNumber;

  Duration? _prevFrameTimeStamp;

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    // should update *before* super.handleBeginFrame, then normal code
    // can see correct [testFrameNumber]
    _testFrameNumber = _testFrameNumber! + 1;

    super.handleBeginFrame(rawTimeStamp);

    _sanityCheckFrameTimeStamp();
    _prevFrameTimeStamp = currentFrameTimeStamp;
  }

  void _sanityCheckFrameTimeStamp() {
    final smoothActive = ServiceLocator.maybeInstance != null;
    if (smoothActive && _prevFrameTimeStamp != null) {
      expect(
        (currentFrameTimeStamp - _prevFrameTimeStamp!).inMicroseconds %
            kOneFrame.inMicroseconds,
        0,
        reason: 'frame timestamp should be multiples of kOneFrame, '
            'otherwise Smooth logic will be wrong '
            'currentFrameTimeStamp=$currentFrameTimeStamp '
            'prevFrameTimeStamp=$_prevFrameTimeStamp ',
      );
    }
  }

  @override
  void elapseBlocking(Duration duration, {String? reason}) {
    if (reason != null) {
      debugPrint('elapseBlocking duration=$duration reason=$reason');
    }
    super.elapseBlocking(duration);
  }

  @override
  AdjustedLastVsyncInfo lastVsyncInfo() {
    // NOTE: this calculation is ONLY valid if beginFrameDateTime
    // is equal to vsync tick time. This does NOT hold for non-testing
    // environments, because of the NotRespectVsync feature
    // also see: #5899

    // we need to *add one frame*, because [(adjusted) VsyncTargetTime] means
    // the end of current plain-old frame, while [beginFrameDateTime] means
    // the clock when plain-old frame starts.
    final currentFrameVsyncTargetDateTime =
        SmoothSchedulerBindingMixin.instance.beginFrameDateTime
            // NOTE this add one frame
            .add(kOneFrame);

    final diffDateTimeTimePoint =
        currentFrameVsyncTargetDateTime.microsecondsSinceEpoch -
            SchedulerBinding.instance.currentFrameTimeStamp.inMicroseconds;

    return _TestAdjustedLastVsyncInfo(
      diffDateTimeTimePoint: diffDateTimeTimePoint,
    );
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

class _TestAdjustedLastVsyncInfo implements AdjustedLastVsyncInfo {
  @override
  final int diffDateTimeTimePoint;

  const _TestAdjustedLastVsyncInfo({required this.diffDateTimeTimePoint});

  @override
  Duration get vsyncTargetTimeAdjusted => throw UnimplementedError();

  @override
  Duration get vsyncTargetTimeRaw => throw UnimplementedError();
}
