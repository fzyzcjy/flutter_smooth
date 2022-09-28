import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

mixin SmoothSchedulerBindingMixin on SchedulerBinding {
  /// The [DateTime] for [currentFrameVsyncTargetTimeStamp]
  DateTime get currentFrameVsyncTargetTime => _currentFrameVsyncTargetTime!;
  DateTime? _currentFrameVsyncTargetTime;

  /// The current VsyncTargetTime
  // p.s. Look at source code, we see:
  // 1. [currentSystemFrameTimeStamp] is VsyncTargetTime
  // 2. [currentFrameTimeStamp] is the adjusted [currentSystemFrameTimeStamp]
  // 3. [currentFrameTimeStamp] is provided to animation callbacks
  Duration get currentFrameVsyncTargetTimeStamp => currentFrameTimeStamp;

  int get diffDateTimeToTimeStamp =>
      currentFrameVsyncTargetTime.microsecondsSinceEpoch -
      currentFrameVsyncTargetTimeStamp.inMicroseconds;

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    // NOTE off-by-one problem
    // By tracing code, [rawTimeStamp] is indeed [VsyncTargetTime],
    // usually the end of this frame.
    // But [clock.now()] is begin of this frame.
    // So we add 16ms to clock.now.
    // #31
    _currentFrameVsyncTargetTime = clock.now().add(kOneFrame);

    super.handleBeginFrame(rawTimeStamp);
  }

  static SmoothSchedulerBindingMixin get instance {
    final raw = WidgetsBinding.instance;
    assert(raw is SmoothSchedulerBindingMixin,
        'Please use a WidgetsBinding with SmoothSchedulerBindingMixin');
    return raw as SmoothSchedulerBindingMixin;
  }

  // TODO make it non-const
  static const kFps = 60;
  static const kOneFrameUs = 1000000 ~/ SmoothSchedulerBindingMixin.kFps;
  static const kOneFrame = Duration(microseconds: kOneFrameUs);
}

// ref [AutomatedTestWidgetsFlutterBinding]
class SmoothWidgetsFlutterBinding extends WidgetsFlutterBinding
    with SmoothSchedulerBindingMixin {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SmoothWidgetsFlutterBinding get instance =>
      BindingBase.checkInstance(_instance);
  static SmoothWidgetsFlutterBinding? _instance;

  // ignore: prefer_constructors_over_static_methods
  static SmoothWidgetsFlutterBinding ensureInitialized() {
    if (SmoothWidgetsFlutterBinding._instance == null) {
      SmoothWidgetsFlutterBinding();
    }
    return SmoothWidgetsFlutterBinding.instance;
  }
}
